import * as functions from 'firebase-functions'
import { sendSlack } from '../repositories/slackRepository';

export const postDrinkTrigger = (collectionName: String) =>
  functions.firestore
    .document(`${collectionName}/{drinkId}`)
    .onCreate((snapshot) => {
      const drink = snapshot.data()
      const detail = `
userName: ${drink.userName}
drinkName: ${drink.drinkName}
drinkType: ${drink.drinkType}
memo: ${drink.memo}
      `
      const dev = collectionName.indexOf('dev') === -1 ? '' : '【開発】'

      void sendSlack(`${dev}お酒が投稿されました。`, detail)
    })
