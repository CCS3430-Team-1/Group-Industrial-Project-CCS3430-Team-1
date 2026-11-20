require("dotenv").config();
const express = require("express");
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);

const app = express();

//Donation Amounts
const PRESETS = [5, 20, 50];
const MIN_AMOUNT = 1;
const MAX_AMOUNT = 1000;

//Create a Stripe Checkout session for a one-time donation
async function createDonationSession(euros) {
  return stripe.checkout.sessions.create({
    mode: "payment",
    line_items: [
      {
        price_data: {
          currency: "eur",
          product_data: { name: "Donation" },
          unit_amount: Math.round(euros * 100), // euros to cents
        },
        quantity: 1,
      },
    ],
    success_url: "http://localhost:3000/success",
    cancel_url: "http://localhost:3000/cancel",
  });
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
    <h2>Donate</h2>
    <p>${buttons}</p>
    <form action="/donate/once" method="GET">
      <label>Other amount (€): <input name="amount" type="number" step="0.01" min="${MIN_AMOUNT}" max="${MAX_AMOUNT}" required></label>
      <button type="submit">Donate</button>
    </form>
  `);
});

app.get("/success", (req, res) => res.send("Thank you!"));
app.get("/cancel", (req, res) => res.send("Cancelled"));

app.listen(3000, () => console.log("Running on http://localhost:3000"));