const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const signToken = (id) => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is not configured');
  }

  return jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });
};

const register = async (req, res, next) => {
  try {
    const { name, email, password, role, age, phone } = req.body;

    if (!name || !email || !password || !role) {
      res.status(400);
      throw new Error('Name, email, password, and role are required');
    }

    if (!['requester', 'volunteer'].includes(role)) {
      res.status(400);
      throw new Error('Role must be requester or volunteer');
    }

    const normalizedEmail = email.trim().toLowerCase();
    const existingUser = await User.findOne({ email: normalizedEmail });

    if (existingUser) {
      res.status(400);
      throw new Error('An account with this email already exists');
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await User.create({
      name,
      email: normalizedEmail,
      passwordHash,
      role,
      age,
      phone,
    });

    res.status(201).json({
      user,
      token: signToken(user.id),
    });
  } catch (error) {
    if (error.code === 11000) {
      res.status(400);
      error.message = 'An account with this email already exists';
    }

    next(error);
  }
};

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      res.status(400);
      throw new Error('Email and password are required');
    }

    const user = await User.findOne({
      email: email.trim().toLowerCase(),
    }).select('+passwordHash');

    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      res.status(401);
      throw new Error('Invalid credentials');
    }

    res.json({
      user,
      token: signToken(user.id),
    });
  } catch (error) {
    next(error);
  }
};

const getMe = async (req, res) => {
  res.json({ user: req.user });
};

module.exports = { register, login, getMe };
