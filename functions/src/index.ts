// import { instanceId } from 'firebase-admin';
import * as functions from 'firebase-functions';
// import { firebaseConfig } from 'firebase-functions';
const admin = require('firebase-admin');
admin.initializeApp();

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = functions.https.onRequest((request, response) => {

//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

export const onMessageCreate = functions.database
  .ref('/Message/{messageRoomID}/{messageID}')
  .onCreate((snapshot, context) => {
    const senderName = snapshot.child('name').val()
    const text = snapshot.child('text').val()
    const targetToken = snapshot.child('targetToken').val()
    const targetUID = snapshot.child('UID').val()

    const payload = {
      notification: 
      {
        title: senderName,
        body: text,
        targetUID : targetUID,
      },
    }

    return admin.messaging().sendToDevice(targetToken, payload)
    .then((response: any) => {
      console.log('Successfully sent message:', response);
    })
    .catch((error: any) => {
      console.log('Error sending message:', error);
    })
    
  })


export const onCommentCreate = functions.database
  .ref('/PersonDetail/{PosterID}/{IWantType}/{itemID}/commentIDs/{commentID}')
  .onCreate((snapshot, context) => {

    const posterID = context.params.PosterID
    const itemID = context.params.itemID
    const iWantType = context.params.IWantType
    const commentID = context.params.commentID
    const itemNameRef = snapshot.ref.parent?.parent?.child('name')
    const subscribedIDsRef = snapshot.ref.parent?.parent?.child('subscribedIDs')
    const reviewerIDRef = snapshot.ref.root.child('Comment').child(itemID).child(commentID).child("UID")

    //step1 找到itemName
    return itemNameRef?.once('value', function (itemNameSnapshot) {
      const itemName = itemNameSnapshot.val()
      //step2 找到reviewerID
      return reviewerIDRef?.once('value', function (reviewerIDSnapshot) {
        const reviewerID = reviewerIDSnapshot.val()
        //step3 找到subscribedIDs
        return subscribedIDsRef?.once('value', function (subscribedIDsnapshot) {
          const promises: Promise<void>[] = []
          subscribedIDsnapshot.forEach((subscriber) => {
            // step4 確認留言者並非訂閱者，自己留的言不需要通知自己
            if (subscriber.key !== reviewerID) {
              if (subscriber.val() && subscriber.key) {
                //step5 確認訂閱者是否為文章擁有者
                let type = ""
                if (subscriber.key === posterID) {
                  type = "1"
                } else {
                  type = "2"
                }

                const notificationRef = snapshot.ref.root.child('Notification').child(subscriber.key).child(itemID)
                const date = new Date()
                date.setTime( date.getTime() + 28800000) //這是加八小時的時差 GMT+8
                const time = dateAsYYYYMMDDHHNNSS(date)
              
                const isRead = "0"
                promises.push(notificationRef.update({ type, posterID, iWantType, itemName, time, isRead }))

                const name = snapshot.val()
                promises.push(notificationRef.child("reviewers").child(name).set(time))

              }
            }
          })
          return Promise.all(promises)
        })


      })


    })

  })



  //YYYYMMDDhhmmss

  function dateAsYYYYMMDDHHNNSS(date:Date): string {

    

    return date.getFullYear()
              + leftpad(date.getMonth() + 1, 2)
              + leftpad(date.getDate(), 2)
              + leftpad(date.getHours(), 2)
              + leftpad(date.getMinutes(), 2)
              + leftpad(date.getSeconds(), 2)
  }
  
  function leftpad(val:number, resultLength = 2, leftpadChar = '0'): string {
    return (String(leftpadChar).repeat(resultLength)
          + String(val)).slice(String(val).length)
  }
  