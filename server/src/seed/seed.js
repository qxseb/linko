const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');
const mongoose = require('mongoose');
const connectDB = require('../config/db');
const HelpRequest = require('../models/HelpRequest');
const Message = require('../models/Message');
const User = require('../models/User');

dotenv.config();

const demoPassword = 'parola123';
const demoEmails = [
  'maria.ionescu@demo.linko',
  'elena.pop@demo.linko',
  'andrei.dima@demo.linko',
  'ioana.stan@demo.linko',
  'vlad.marin@demo.linko',
];

const daysFromNow = (days, hours = 9) => {
  const date = new Date();
  date.setDate(date.getDate() + days);
  date.setHours(hours, 0, 0, 0);
  return date;
};

const clearDemoData = async () => {
  const demoUsers = await User.find({ email: { $in: demoEmails } }).select('_id');
  const demoUserIds = demoUsers.map((user) => user._id);

  const demoRequests = await HelpRequest.find({
    $or: [
      { requester: { $in: demoUserIds } },
      { assignedVolunteer: { $in: demoUserIds } },
    ],
  }).select('_id');
  const demoRequestIds = demoRequests.map((request) => request._id);

  await Message.deleteMany({ request: { $in: demoRequestIds } });
  await HelpRequest.deleteMany({ _id: { $in: demoRequestIds } });
  await User.deleteMany({ email: { $in: demoEmails } });
};

const seed = async () => {
  await connectDB();
  await clearDemoData();

  const passwordHash = await bcrypt.hash(demoPassword, 10);

  const [maria, elena, andrei, ioana, vlad] = await User.insertMany([
    {
      name: 'Maria Ionescu',
      email: 'maria.ionescu@demo.linko',
      passwordHash,
      role: 'requester',
      age: 72,
      phone: '0722 104 889',
      responseTime: 'aprox. 15 min',
    },
    {
      name: 'Elena Pop',
      email: 'elena.pop@demo.linko',
      passwordHash,
      role: 'requester',
      age: 67,
      phone: '0744 318 502',
      responseTime: 'aprox. 20 min',
    },
    {
      name: 'Andrei Dima',
      email: 'andrei.dima@demo.linko',
      passwordHash,
      role: 'requester',
      age: 41,
      phone: '0731 887 219',
      responseTime: 'aprox. 10 min',
    },
    {
      name: 'Ioana Stan',
      email: 'ioana.stan@demo.linko',
      passwordHash,
      role: 'volunteer',
      age: 29,
      phone: '0756 220 144',
      completedTasks: 8,
      responseTime: 'aprox. 8 min',
    },
    {
      name: 'Vlad Marin',
      email: 'vlad.marin@demo.linko',
      passwordHash,
      role: 'volunteer',
      age: 34,
      phone: '0729 551 603',
      completedTasks: 4,
      responseTime: 'aprox. 12 min',
    },
  ]);

  const [
    insulinRequest,
    proxyCheckInRequest,
    groceriesRequest,
    errandsRequest,
    completedPharmacyRequest,
  ] = await HelpRequest.insertMany([
    {
      requester: maria._id,
      category: 'pharmacy',
      title: 'Insulin from the pharmacy',
      description:
        'I ran out of insulin for tonight. The prescription is ready at Farmacia Tei and only needs to be picked up and brought home.',
      locationText: 'Str. Baba Novac 18, Bucuresti',
      latitude: 44.4217,
      longitude: 26.1394,
      distanceText: '1,2 km',
      urgency: 'high',
      status: 'open',
      preferredTime: daysFromNow(0, 18),
    },
    {
      requester: andrei._id,
      category: 'checkin',
      title: 'Quick check-in for my father',
      description:
        'My father has not answered the phone since this morning. He is probably sleeping, but I would like someone to check that he is okay.',
      locationText: 'Bd. Iuliu Maniu 59, Bucuresti',
      latitude: 44.4348,
      longitude: 26.0342,
      distanceText: '2,8 km',
      urgency: 'high',
      status: 'open',
      preferredTime: daysFromNow(0, 14),
      isProxyRequest: true,
      proxyName: 'Gheorghe Dima',
      proxyRelationship: 'father',
      proxyNotes: 'He is 76. The building manager knows him by name.',
    },
    {
      requester: elena._id,
      assignedVolunteer: ioana._id,
      category: 'groceries',
      title: 'A few basic groceries',
      description:
        'Bread, milk, eggs, and two plain yogurts. If you cannot find the usual brand, any option is fine.',
      locationText: 'Calea Mosilor 221, Bucuresti',
      latitude: 44.4476,
      longitude: 26.1169,
      distanceText: '900 m',
      urgency: 'medium',
      status: 'accepted',
      preferredTime: daysFromNow(1, 10),
    },
    {
      requester: maria._id,
      category: 'errands',
      title: 'Registered letter at the post office',
      description:
        'I have a registered letter to pick up from the post office. I can leave my ID and authorization with the building concierge.',
      locationText: 'Piata Alba Iulia, Bucuresti',
      latitude: 44.4259,
      longitude: 26.1305,
      distanceText: '1,6 km',
      urgency: 'low',
      status: 'open',
      preferredTime: daysFromNow(2, 11),
    },
    {
      requester: elena._id,
      assignedVolunteer: vlad._id,
      category: 'pharmacy',
      title: 'Blood pressure prescription',
      description:
        'A box of blood pressure medication needed to be picked up. The prescription was already in the pharmacy system.',
      locationText: 'Sos. Stefan cel Mare 12, Bucuresti',
      latitude: 44.4521,
      longitude: 26.1037,
      distanceText: '1,1 km',
      urgency: 'medium',
      status: 'completed',
      preferredTime: daysFromNow(-1, 16),
    },
  ]);

  await Message.insertMany([
    {
      request: groceriesRequest._id,
      text: 'Ioana Stan accepted the request.',
      type: 'system',
    },
    {
      request: groceriesRequest._id,
      sender: elena._id,
      text: 'Hi Ioana. Thank you so much. Regular milk, not skimmed, if possible.',
      type: 'user',
    },
    {
      request: groceriesRequest._id,
      sender: ioana._id,
      text: 'Hi! Of course. I will stop by Mega after lunch and message you if I cannot find something.',
      type: 'user',
    },
    {
      request: groceriesRequest._id,
      sender: elena._id,
      text: 'Perfect, there is no rush. Thank you again.',
      type: 'user',
    },
    {
      request: completedPharmacyRequest._id,
      text: 'Vlad Marin accepted the request.',
      type: 'system',
    },
    {
      request: completedPharmacyRequest._id,
      sender: vlad._id,
      text: 'Hello, I will reach the pharmacy in about 20 minutes.',
      type: 'user',
    },
    {
      request: completedPharmacyRequest._id,
      sender: elena._id,
      text: 'Thank you, Vlad. If they ask, the medication is under Elena Pop.',
      type: 'user',
    },
    {
      request: completedPharmacyRequest._id,
      text: 'Vlad Marin started the request.',
      type: 'system',
    },
    {
      request: completedPharmacyRequest._id,
      sender: vlad._id,
      text: 'I picked it up. It was 27 lei and I have the receipt.',
      type: 'user',
    },
    {
      request: completedPharmacyRequest._id,
      sender: elena._id,
      text: 'Great, I will come downstairs in 5 minutes.',
      type: 'user',
    },
    {
      request: completedPharmacyRequest._id,
      text: 'Vlad Marin completed the request.',
      type: 'system',
    },
  ]);

  console.log('Demo data inserted successfully.');
  console.log('');
  console.log('Demo credentials:');
  console.log(`Password for all demo users: ${demoPassword}`);
  console.log('');
  console.log('Requesters:');
  console.log('  maria.ionescu@demo.linko');
  console.log('  elena.pop@demo.linko');
  console.log('  andrei.dima@demo.linko');
  console.log('');
  console.log('Volunteers:');
  console.log('  ioana.stan@demo.linko');
  console.log('  vlad.marin@demo.linko');
  console.log('');
  console.log('Created requests:');
  console.log(`  urgent insulin: ${insulinRequest._id}`);
  console.log(`  urgent proxy check-in: ${proxyCheckInRequest._id}`);
  console.log(`  accepted groceries: ${groceriesRequest._id}`);
  console.log(`  open errands: ${errandsRequest._id}`);
  console.log(`  completed pharmacy: ${completedPharmacyRequest._id}`);
};

seed()
  .catch((error) => {
    console.error(`Seed failed: ${error.message}`);
    process.exitCode = 1;
  })
  .finally(async () => {
    await mongoose.disconnect();
  });
