require("dotenv").config();
const express = require("express");

const app = express();

//Donation Amounts
const PRESETS = [5, 20, 50];
const MIN_AMOUNT = 1;
const MAX_AMOUNT = 1000;

//Viva demo API credentials
const TOKEN_URL = "https://demo-accounts.vivapayments.com/connect/token";
const ORDERS_URL = "https://demo-api.vivapayments.com/checkout/v2/orders";
const CHECKOUT_URL = "https://demo.vivapayments.com/web/checkout";

//Get an access token from Viva
async function getAccessToken() {
  const credentials = Buffer.from(
    `${process.env.VIVA_CLIENT_ID}:${process.env.VIVA_CLIENT_SECRET}`
  ).toString("base64");

  const response = await fetch(TOKEN_URL, {
    method: "POST",
    headers: {
      Authorization: `Basic ${credentials}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials",
  });

  const data = await response.json();
  if (!response.ok) throw new Error(JSON.stringify(data));
  return data.access_token;
}

//Create a Viva Checkout session for a one-time donation
async function createDonationSession(euros) {
  const token = await getAccessToken();

  const response = await fetch(ORDERS_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      amount: Math.round(euros * 100), // euros to cents
      sourceCode: process.env.VIVA_SOURCE_CODE,
      customerTrns: "Donation",
      customer: { requestLang: "en-GB" },
    }),
  });

  const data = await response.json();
  if (!response.ok) throw new Error(JSON.stringify(data));

  return { url: `${CHECKOUT_URL}?ref=${data.orderCode}` };
}

//Handle the donation request
app.get("/donate/once", async (req, res) => {
  const euros = Number(req.query.amount);

  //Check if the amount is valid
  if (!Number.isFinite(euros) || euros < MIN_AMOUNT || euros > MAX_AMOUNT) {
    return res.status(400).send("Invalid amount");
  }

  try {
    const session = await createDonationSession(euros);
    res.redirect(session.url);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Something went wrong: " + err.message);
  }
});

//Render the donation page with preset buttons and a custom amount form
app.get("/", (req, res) => {
  const buttons = PRESETS.map(
    (p) => `<a href="/donate/once?amount=${p}"><button>€${p}</button></a>`
  ).join(" ");

  res.send(`
    <h2>Donate (Viva)</h2>
    <p>${buttons}</p>
    <form action="/donate/once" method="GET">
      <label>Other amount (€): <input name="amount" type="number" step="0.01" min="${MIN_AMOUNT}" max="${MAX_AMOUNT}" required></label>
      <button type="submit">Donate</button>
    </form>
  `);
});

app.get("/success", (req, res) => res.send("Thank you!"));
app.get("/cancel", (req, res) => res.send("Cancelled"));

app.listen(3001, () => console.log("Running on http://localhost:3001"));