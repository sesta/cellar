import * as functions from 'firebase-functions'
import { sendSlack } from '../repositories/slackRepository';

export const postDrinkTrigger = (collectionName: String) =>
  functions.firestore
    .document(`${collectionName}/{drinkId}`)
    .onCreate((snapshot) => {
      const drink = snapshot.data()
      const detail = `お酒の名前: ${drink.name}`
      const dev = collectionName.indexOf('dev') === -1 ? '' : '【開発】'

      void sendSlack(`${dev}お酒が投稿されました。`, detail)
    })
