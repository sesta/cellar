import * as functions from 'firebase-functions'

export const postDrinkTrigger = (collectionName: String) =>
  functions.firestore
    .document(`${collectionName}/{drinkId}`)
    .onCreate((snapshot) => {
      const drink = snapshot.data()
      console.log(`${collectionName}でお酒が投稿されました。`)
      console.log(drink)
    })
