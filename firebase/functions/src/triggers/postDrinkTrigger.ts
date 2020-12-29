import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'

import { notifyPost } from '../repositories/slackRepository'

export const postDrinkTrigger = (collectionName: String) =>
  functions.firestore
    .document(`${collectionName}/{drinkId}`)
    .onCreate((snapshot) => {
      const bucket = admin.storage().bucket()
      const drink = snapshot.data()
      const image = bucket.file(drink.thumbImagePath)

      image.getSignedUrl({
        action: 'read',
        // 雑に未来にしておく
        expires: '2030-01-01',
      }).then((imageUrls) => {
        void notifyPost(
          {
            drinkId: snapshot.id,
            drinkName: drink.drinkName,
            userName: drink.userName,
            drinkType: drink.drinkType,
            memo: drink.memo,
            imageUrl: imageUrls[0],
          },
          collectionName.indexOf('dev') === -1,
        )
      }).catch((error) => {
        console.log(error)
      })
    })
