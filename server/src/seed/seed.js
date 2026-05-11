/**
 * Seed script for Linko demo data.
 *
 * STAT APPROACH:
 *   - completedTasks  (User, volunteer): stored counter = # of HelpRequests
 *     where assignedVolunteer = this user AND status = 'completed'.
 *   - completedRequests (User, requester): stored counter = # of HelpRequests
 *     where requester = this user AND status = 'completed'.
 *   - Both are also recomputed dynamically in /auth/me and /login, so they
 *     are always accurate regardless of seed values.
 *
 * SEEDED COMPLETIONS:
 *   Ioana handled requests: comp_maria_pharmacy, comp_elena_groceries, comp_andrei_checkin
 *     → ioana.completedTasks = 3
 *   Vlad handled request: comp_elena_pharmacy
 *     → vlad.completedTasks = 1
 *   Maria had 1 request completed for her (comp_maria_pharmacy)
 *     → maria.completedRequests = 1
 *   Elena had 2 requests completed for her (comp_elena_pharmacy, comp_elena_groceries)
 *     → elena.completedRequests = 2
 *   Andrei had 1 request completed for him (comp_andrei_checkin)
 *     → andrei.completedRequests = 1
 */

const bcrypt = require("bcryptjs");
const dotenv = require("dotenv");
const mongoose = require("mongoose");
const connectDB = require("../config/db");
const HelpRequest = require("../models/HelpRequest");
const Message = require("../models/Message");
const User = require("../models/User");

dotenv.config();

const DEMO_PASSWORD = "parola123";
const DEMO_EMAILS = [
  "maria.ionescu@demo.linko",
  "elena.pop@demo.linko",
  "andrei.dima@demo.linko",
  "ioana.stan@demo.linko",
  "vlad.marin@demo.linko",
];

const daysFromNow = (days, hours = 9) => {
  const d = new Date();
  d.setDate(d.getDate() + days);
  d.setHours(hours, 0, 0, 0);
  return d;
};

const clearDemoData = async () => {
  const demoUsers = await User.find({ email: { $in: DEMO_EMAILS } }).select(
    "_id",
  );
  const ids = demoUsers.map((u) => u._id);

  const demoRequests = await HelpRequest.find({
    $or: [{ requester: { $in: ids } }, { assignedVolunteer: { $in: ids } }],
  }).select("_id");

  await Message.deleteMany({
    request: { $in: demoRequests.map((r) => r._id) },
  });
  await HelpRequest.deleteMany({
    _id: { $in: demoRequests.map((r) => r._id) },
  });
  await User.deleteMany({ email: { $in: DEMO_EMAILS } });
};

const seed = async () => {
  await connectDB();
  await clearDemoData();

  const passwordHash = await bcrypt.hash(DEMO_PASSWORD, 10);

  const [maria, elena, andrei, ioana, vlad] = await User.insertMany([
    {
      name: "Maria Ionescu",
      email: "maria.ionescu@demo.linko",
      passwordHash,
      role: "requester",
      age: 72,
      phone: "0722 104 889",
      completedRequests: 1,
    },
    {
      name: "Elena Pop",
      email: "elena.pop@demo.linko",
      passwordHash,
      role: "requester",
      age: 67,
      phone: "0744 318 502",
      completedRequests: 2,
    },
    {
      name: "Andrei Dima",
      email: "andrei.dima@demo.linko",
      passwordHash,
      role: "requester",
      age: 41,
      phone: "0731 887 219",
      completedRequests: 1,
    },
    {
      name: "Ioana Stan",
      email: "ioana.stan@demo.linko",
      passwordHash,
      role: "volunteer",
      age: 29,
      phone: "0756 220 144",
      completedTasks: 3,
      responseTime: 8,
    },
    {
      name: "Vlad Marin",
      email: "vlad.marin@demo.linko",
      passwordHash,
      role: "volunteer",
      age: 34,
      phone: "0729 551 603",
      completedTasks: 1,
      responseTime: 12,
    },
  ]);

  const [insulinReq, errandsReq, groceriesAccepted, checkinInProgress] =
    await HelpRequest.insertMany([
      {
        requester: maria._id,
        category: "pharmacy",
        title: "Insulin from the pharmacy",
        description:
          "I ran out of insulin for tonight. The prescription is ready at Farmacia Tei and only needs to be picked up and brought home.",
        locationText: "Str. Baba Novac 18, Bucharest",
        latitude: 44.4217,
        longitude: 26.1394,
        distanceText: "1.2 km",
        urgency: "high",
        status: "open",
        preferredTime: daysFromNow(0, 18),
      },
      {
        requester: maria._id,
        category: "errands",
        title: "Registered letter at the post office",
        description:
          "I have a registered letter to pick up from the post office. I can leave my ID and authorization with the building concierge.",
        locationText: "Piata Alba Iulia, Bucharest",
        latitude: 44.4259,
        longitude: 26.1305,
        distanceText: "1.6 km",
        urgency: "low",
        status: "open",
        preferredTime: daysFromNow(2, 11),
      },
      {
        requester: elena._id,
        assignedVolunteer: ioana._id,
        category: "groceries",
        title: "A few basic groceries",
        description:
          "Bread, milk, eggs, and two plain yogurts. If you cannot find the usual brand, any option is fine.",
        locationText: "Calea Mosilor 221, Bucharest",
        latitude: 44.4476,
        longitude: 26.1169,
        distanceText: "900 m",
        urgency: "medium",
        status: "accepted",
        preferredTime: daysFromNow(1, 10),
      },
      {
        requester: andrei._id,
        assignedVolunteer: vlad._id,
        category: "checkin",
        title: "Check on my father",
        description:
          "My father has not answered the phone since this morning. He is probably sleeping, but I would like someone to check that he is okay.",
        locationText: "Bd. Iuliu Maniu 59, Bucharest",
        latitude: 44.4348,
        longitude: 26.0342,
        distanceText: "2.8 km",
        urgency: "high",
        status: "in_progress",
        preferredTime: daysFromNow(0, 14),
        isProxyRequest: true,
        proxyName: "Gheorghe Dima",
        proxyRelationship: "father",
        proxyNotes: "He is 76. The building manager knows him by name.",
      },
    ]);

  const [compElenaPharmacy, compMariaPharmacy, compElenaGroceries, compAndrei] =
    await HelpRequest.insertMany([
      {
        requester: elena._id,
        assignedVolunteer: vlad._id,
        category: "pharmacy",
        title: "Blood pressure prescription",
        description:
          "A box of blood pressure medication needed to be picked up. The prescription was already in the pharmacy system.",
        locationText: "Sos. Stefan cel Mare 12, Bucharest",
        latitude: 44.4521,
        longitude: 26.1037,
        distanceText: "1.1 km",
        urgency: "medium",
        status: "completed",
        preferredTime: daysFromNow(-3, 16),
        completedAt: daysFromNow(-3, 17),
      },
      {
        requester: maria._id,
        assignedVolunteer: ioana._id,
        category: "pharmacy",
        title: "Weekly vitamins and supplements",
        description:
          "A box of vitamin D and omega-3. They are available at any pharmacy.",
        locationText: "Str. Unirii 8, Bucharest",
        latitude: 44.4268,
        longitude: 26.1025,
        distanceText: "0.8 km",
        urgency: "low",
        status: "completed",
        preferredTime: daysFromNow(-8, 11),
        completedAt: daysFromNow(-8, 12),
      },
      {
        requester: elena._id,
        assignedVolunteer: ioana._id,
        category: "groceries",
        title: "Small grocery run",
        description:
          "Just some bread and butter. Nothing heavy — she lives on the second floor with no elevator.",
        locationText: "Mega Image, Calea Mosilor, Bucharest",
        latitude: 44.4502,
        longitude: 26.121,
        distanceText: "0.5 km",
        urgency: "low",
        status: "completed",
        preferredTime: daysFromNow(-15, 10),
        completedAt: daysFromNow(-15, 11),
      },
      {
        requester: andrei._id,
        assignedVolunteer: ioana._id,
        category: "checkin",
        title: "Quick check-in visit",
        description:
          "Please check on my elderly neighbor. She lives alone and has been unwell.",
        locationText: "Str. Florilor 12, Bucharest",
        latitude: 44.431,
        longitude: 26.0985,
        distanceText: "1.9 km",
        urgency: "high",
        status: "completed",
        preferredTime: daysFromNow(-11, 15),
        completedAt: daysFromNow(-11, 16),
      },
    ]);

  await Message.insertMany([
    {
      request: groceriesAccepted._id,
      text: "Ioana Stan accepted the request.",
      type: "system",
    },
    {
      request: groceriesAccepted._id,
      sender: elena._id,
      text: "Hi Ioana. Thank you so much. Regular milk, not skimmed, if possible.",
      type: "user",
    },
    {
      request: groceriesAccepted._id,
      sender: ioana._id,
      text: "Hi! Of course. I will stop by Mega after lunch and message you if I cannot find something.",
      type: "user",
    },
    {
      request: groceriesAccepted._id,
      sender: elena._id,
      text: "Perfect, there is no rush. Thank you again.",
      type: "user",
    },

    {
      request: checkinInProgress._id,
      text: "Vlad Marin accepted the request.",
      type: "system",
    },
    {
      request: checkinInProgress._id,
      sender: andrei._id,
      text: "Hi Vlad. He is on the third floor, apartment 8. The door code is 1234.",
      type: "user",
    },
    {
      request: checkinInProgress._id,
      sender: vlad._id,
      text: "On my way now. I will message you as soon as I see him.",
      type: "user",
    },
    {
      request: checkinInProgress._id,
      text: "Vlad Marin started the request.",
      type: "system",
    },
    {
      request: checkinInProgress._id,
      sender: vlad._id,
      text: "I am outside the building now.",
      type: "user",
    },

    {
      request: compElenaPharmacy._id,
      text: "Vlad Marin accepted the request.",
      type: "system",
    },
    {
      request: compElenaPharmacy._id,
      sender: vlad._id,
      text: "Hello, I will reach the pharmacy in about 20 minutes.",
      type: "user",
    },
    {
      request: compElenaPharmacy._id,
      sender: elena._id,
      text: "Thank you, Vlad. If they ask, the medication is under Elena Pop.",
      type: "user",
    },
    {
      request: compElenaPharmacy._id,
      text: "Vlad Marin started the request.",
      type: "system",
    },
    {
      request: compElenaPharmacy._id,
      sender: vlad._id,
      text: "I picked it up. It was 27 lei and I have the receipt.",
      type: "user",
    },
    {
      request: compElenaPharmacy._id,
      sender: elena._id,
      text: "Great, I will come downstairs in 5 minutes.",
      type: "user",
    },
    {
      request: compElenaPharmacy._id,
      text: "Vlad Marin completed the request.",
      type: "system",
    },

    {
      request: compMariaPharmacy._id,
      text: "Ioana Stan accepted the request.",
      type: "system",
    },
    {
      request: compMariaPharmacy._id,
      sender: ioana._id,
      text: "Good morning! I can stop by the pharmacy this morning.",
      type: "user",
    },
    {
      request: compMariaPharmacy._id,
      sender: maria._id,
      text: "Thank you dear. The vitamins are on the shelf next to the counter, just ask for them.",
      type: "user",
    },
    {
      request: compMariaPharmacy._id,
      text: "Ioana Stan started the request.",
      type: "system",
    },
    {
      request: compMariaPharmacy._id,
      sender: ioana._id,
      text: "Got them! Heading to your place now.",
      type: "user",
    },
    {
      request: compMariaPharmacy._id,
      text: "Ioana Stan completed the request.",
      type: "system",
    },
  ]);

  console.log("");
  console.log("Demo data seeded successfully.");
  console.log("");
  console.log("Password for all demo accounts: " + DEMO_PASSWORD);
  console.log("");
  console.log("Requesters:");
  console.log("  maria.ionescu@demo.linko  (1 completed request)");
  console.log("  elena.pop@demo.linko      (2 completed requests)");
  console.log("  andrei.dima@demo.linko    (1 completed request)");
  console.log("");
  console.log("Volunteers:");
  console.log("  ioana.stan@demo.linko     (3 completed tasks)");
  console.log("  vlad.marin@demo.linko     (1 completed task)");
  console.log("");
  console.log("Active requests:");
  console.log("  OPEN        insulin:      " + insulinReq._id);
  console.log("  OPEN        errands:      " + errandsReq._id);
  console.log("  ACCEPTED    groceries:    " + groceriesAccepted._id);
  console.log("  IN_PROGRESS checkin:      " + checkinInProgress._id);
  console.log("");
  console.log("Completed requests:");
  console.log("  Elena pharmacy (Vlad):    " + compElenaPharmacy._id);
  console.log("  Maria pharmacy (Ioana):   " + compMariaPharmacy._id);
  console.log("  Elena groceries (Ioana):  " + compElenaGroceries._id);
  console.log("  Andrei checkin (Ioana):   " + compAndrei._id);
};

seed()
  .catch((error) => {
    console.error("Seed failed: " + error.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    await mongoose.disconnect();
  });
