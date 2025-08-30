const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const COLOR = process.env.APP_COLOR || 'unknown';

app.get('/', (req, res) => res.send(`Hello from ${COLOR}!`));
app.get('/health', (req, res) => res.send('OK'));

app.listen(PORT, () => {
  console.log(`App running on port ${PORT} as ${COLOR}`);
});
