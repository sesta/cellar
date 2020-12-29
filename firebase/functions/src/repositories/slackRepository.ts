import axios from 'axios'

type Drink = {
  drinkId: string
  drinkName: string
  userName: string
  drinkType: string
  memo: string
  imageUrl: string
}

export const notifyPost = async (drink: Drink, isProduction: boolean) => {
  const text = `${isProduction? '' : '【開発】'}お酒が投稿されました。`
  // cloud functionsの環境変数で設定
  const url = process.env.SLACK_URL as string
  const data = {
    text,
    blocks: [
      {
        type: 'section',
        text: {
          type: 'plain_text',
          text: text,
        },
      },
      {
        type: 'context',
        elements: [
          {
            type: 'plain_text',
            text: `${drink.userName} / ${drink.drinkType} / ${drink.drinkId}`,
          },
        ],
      },
      {
        type: 'section',
        text: {
          type: 'plain_text',
          text: drink.drinkName,
        },
      },
      {
        type: 'context',
        elements: [
          {
            type: 'plain_text',
            text: drink.memo === '' ? '-' : drink.memo,
          },
        ],
      },
      {
        type: 'image',
        image_url: drink.imageUrl,
        alt_text: 'drinkImage',
      },
    ],
  }
  const config = {
    headers: {
      'content-type': 'application/json',
    },
  }

  try {
    await axios.post(
      url,
      data,
      config,
    )
  } catch (error) {
    console.log(error)
  }
}
