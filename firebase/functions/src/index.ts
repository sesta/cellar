import * as functions from 'firebase-functions'

exports.trigger = functions.firestore
  .document('dev-drinks/{drinkId}')
  .onCreate((snapshot) => {
    console.log('お酒が投稿されました')
    console.log(snapshot)
  })
