import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'

import { postDrinkTrigger } from "./triggers/postDrinkTrigger"

// cloud functionsの環境変数で設定
const storageBucket = functions.config().storage.bucket
admin.initializeApp({
  storageBucket,
})

exports.postDrinkTriggerDev = postDrinkTrigger('dev-drinks')
exports.postDrinkTrigger = postDrinkTrigger('drinks')
