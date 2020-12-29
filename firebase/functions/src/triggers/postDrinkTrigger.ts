import * as functions from 'firebase-functions'
import { notifyPost } from '../repositories/slackRepository'

export const postDrinkTrigger = (collectionName: String) =>
  functions.firestore
    .document(`${collectionName}/{drinkId}`)
    .onCreate((snapshot) => {
      const drink = snapshot.data()

      void notifyPost(
        {
          drinkId: snapshot.id,
          drinkName: drink.drinkName,
          userName: drink.userName,
          drinkType: drink.drinkType,
          memo: drink.memo,
        },
        collectionName.indexOf('dev') === -1,
      )
    })
