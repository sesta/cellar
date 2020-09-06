import axios from 'axios'

export const sendSlack = async (message: String, detail: string) => {
  const url = ''
  const data = {
    text: message,
    blocks: [
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: message,
        }
      },
      {
        type: 'context',
        elements: [
          {
            type: 'mrkdwn',
            text: detail
          }
        ]
      }
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
