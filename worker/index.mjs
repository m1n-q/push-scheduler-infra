export const handler = async (event) => {
  console.log(event);
  const res = await fetch(event.webhook_url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      "tag": "text",
      "text": {
        "format": 1,
        "content": event.content,
      }
    }),
  }).catch(console.error);
};
