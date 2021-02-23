import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:evs_project/models/usermodel.dart';
import 'dart:core';
import 'package:intl/intl.dart';
class Methods
{
  FirebaseAuth _auth;
  GoogleSignIn _googleSignIn = new GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut() async
  {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    return await FirebaseAuth.instance.signOut();
  }

  Future<bool> authenticateUser(User user) async
  {
    QuerySnapshot result = await FirebaseFirestore.instance.collection("users").where("email", isEqualTo: user.email).get();
    final List<DocumentSnapshot> docs = result.docs;
    return docs.length==0?true:false;
  }

  Future<bool> isAdmin(User user) async
  {
    QuerySnapshot result = await FirebaseFirestore.instance.collection("users").where("uid", isEqualTo: user.uid).get();
    //print("Query resu = " + result.docs[0].data()['admin']);
    return result.docs[0].data()['admin'];
  }
  isAdmin2(User user)
  {
    return FirebaseFirestore.instance.collection("users").where("uid", isEqualTo: user.uid).snapshots();
  }
  Future<User> getCurrentUser() async
  {
    return await FirebaseAuth.instance.currentUser;
  }

  Future<void> uploadData(User user) async
  {

    UserModel model = new UserModel(uid: user.uid, email: user.email, photoURL: user.photoURL, name: user.displayName,admin: false);
    FirebaseFirestore.instance.collection("users").doc(user.uid).set(model.getMapfromUser());
  }

  Future<void> uploadQuiz(Map m) async
  {
    FirebaseFirestore.instance.collection("quizzes").doc(m['title']).set(m);
  }

  Future<void> uploadQuestion(Map m, String quizId, String question) async
  {
    FirebaseFirestore.instance.collection("quizzes").doc(quizId).collection("questions").doc(question).set(m).then((value)
    {
      FirebaseFirestore.instance.collection("quizzes").doc(quizId).update({'questioncount':FieldValue.increment(1)});

    });

  }
  
  Future<void> uploadUserAttempt(Map m, String quizid, User user, int question) async
  {
    FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("attempts").doc(user.displayName).collection("questions").doc(question.toString()).set(m);
  }

  Future<void> initialiseQuizStatistic(String quizid, String question, String correctanswer) async
  {
    Map<String, dynamic> m =
    {
      'question':question,
      'correctanswer': correctanswer,
      'attempts': 0,
      'correct':0
    };
    FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("stats").doc(question).set(m);
  }

  Future<void> uploadQuestionStatistic(String quizid, String username) async
  {
    QuerySnapshot res = await FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("attempts").doc(username).collection("questions").get();
    int c=0;
    for(int i=0; i<res.docs.length; i++)
    {
      FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("stats").doc(res.docs[i].data()['question']).update({'attempts':FieldValue.increment(1)});
      if(res.docs[i].data()['correct'] == res.docs[i].data()['selected'])
      {
        c++;
        FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("stats").doc(res.docs[i].data()['question']).update({'correct':FieldValue.increment(1)});
      }
    }
    FirebaseFirestore.instance.collection("users").where('name',isEqualTo: username).get().then((value)
    {
      FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("attempts").doc(username).set({'correct':c, 'photourl':value.docs[0].data()['photoURL'], 'time':FieldValue.serverTimestamp()});
    });

  }

  Future<void> setSurveySelectedOption(String quizid, String question, String option) async
  {
    FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("questions").where('question',isEqualTo: question).get().then((value)
    {
      FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("questions").doc(value.docs[0].id).collection("options").doc(option).update({'count':FieldValue.increment(1)});

    });
  }

  Future<void> addUserAttemptForSurvey(String quizid, User user)
  {
    Map<String, dynamic> m =
    {
      'name':user.displayName,
      'time':FieldValue.serverTimestamp(),
      'photourl':user.photoURL,
    };
    FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("attempts").doc(user.displayName).set(m);
  }

  Future<bool> checkIfUserAttemptedSurvey(String quizid, User user) async
  {
    QuerySnapshot res = await FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("attempts").where('name',isEqualTo: user.displayName).get();
    if(res==null || res.docs.length==0) return false;
    else return true;
  }

  Future<void> initialiseSurvey(String quizid, String question, String option) async
  {
    Map<String, dynamic> m =
    {
      'option':option,
      'count':0
    };
    FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("questions").where('question',isEqualTo: question).get().then((value)
    {
      FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("questions").doc(value.docs[0].id).collection("options").doc(option).set(m);

    });




  }

  getBestPerformers(String quizid)
  {
    return FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("attempts").orderBy('correct',descending: true).snapshots();
  }
  getQuestionStats(String quizid)
  {
    return FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("stats").snapshots();
  }
  
  getQuizzes()
  {
    return FirebaseFirestore.instance.collection("quizzes").snapshots();
  }
  getQuestions(String quizid)
  {
    return FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("questions").snapshots();
  }
  getQuizResult(String quizid, String username)
  {
    return FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("attempts").doc(username).collection("questions").snapshots();
  }

  getSurveyQuestionResult(String quizid)
  {
    return FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("questions").snapshots();
  }

  getSurveyOptionResult(String quizid, String question)
  {
    return FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("questions").doc(question).collection("options").snapshots();
  }

  getSurveyRespondents(String quizid)
  {
    return FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("attempts").snapshots();
  }

  Future<bool> hasUserAttempted(String username, String quizid) async
  {
    QuerySnapshot res = await FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("attempts").doc(username).collection("questions").get();
    if(res==null || res.docs.length==0) return false;
    else return true;
  }

  Future<List<int>> getQuizScore(String quizid, String username) async
  {
    QuerySnapshot res = await FirebaseFirestore.instance.collection("quizzes").doc(quizid).collection("attempts").doc(username).collection("questions").get();
    int count=0;
    for(int i=0; i<res.docs.length; i++)
    {

        if(res.docs[i].data()['correct'] == res.docs[i].data()['selected'])
        {
            count++;
        }

    }
    List<int> x = [count, res.docs.length];
    return x;
    //result.docs[0].data()['admin'];
  }

  Future<int> getQuestionCount(String quizid) async
  {
    QuerySnapshot res = await FirebaseFirestore.instance.collection("quizzes").where('title',isEqualTo: quizid).get();
    return res.docs[0].data()['questioncount'];
  }
  Future<void> uploadLastLoginTime(User user)
  {
    FirebaseFirestore.instance.collection("users").doc(user.uid).update({'lastLogin':FieldValue.serverTimestamp()});
  }

  Future<void> addToLog(String log)
  {

    String time = (DateTime.now().toString()).substring(0,19);
    String t = DateFormat('hh:mm a').format(DateTime.now());
    String t1 = DateFormat('yyyy-MM-dd – kk:mm:ss:ms a'). format(DateTime.now());
    FirebaseFirestore.instance.collection("logs").doc(t1).set({'activity':log, 'time':t1,'servertime':FieldValue.serverTimestamp()});
    //FirebaseFirestore.instance.collection("logs").doc("log").update({t1:log});
  }
  getAdminLogs()
  {
    return FirebaseFirestore.instance.collection("logs").orderBy('servertime').snapshots();
  }

}