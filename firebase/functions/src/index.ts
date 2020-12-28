import { postDrinkTrigger } from "./triggers/postDrinkTrigger"

exports.postDrinkTriggerDev = postDrinkTrigger('dev-drinks')
exports.postDrinkTrigger = postDrinkTrigger('drinks')
