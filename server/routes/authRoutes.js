const express = require('express');
const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require('../config');
const router = express.Router();

// Register a new user
router.post('/register', async (req, res) => {
  const { username, email, password, userType } = req.body;

  if (!username || !email || !password || !userType) {
    return res.status(400).send({ error: 'All fields are required' });
  }

  if (!['user', 'customer_care'].includes(userType)) {
    return res.status(400).send({ error: 'Invalid user type' });
  }

  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).send({ error: 'Email already in use' });
    }

    const user = new User({ username, email, password, userType });
    await user.save();

    res.status(201).send({ message: 'User registered successfully' });
  } catch (error) {
    res.status(500).send({ error: 'Error registering user' });
  }
});

// Login a user
router.post('/login', async (req, res) => {
  const { email, password, userType } = req.body;

  if (!email || !password || !userType) {
    return res.status(400).send({ error: 'All fields are required' });
  }

  if (!['user', 'customer_care'].includes(userType)) {
    return res.status(400).send({ error: 'Invalid user type' });
  }

  try {
    const user = await User.findOne({ email, userType });
    if (!user) {
      return res.status(400).send({ error: 'Invalid login credentials' });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(400).send({ error: 'Invalid login credentials' });
    }

    const token = jwt.sign({ userId: user._id, userType: user.userType }, config.secret, {
      expiresIn: '1h',
    });

    res.send({ token, userType: user.userType });
  } catch (error) {
    res.status(500).send({ error: 'Error logging in' });
  }
});



router.get('/userdetails', async (req, res) => {
  const { email } = req.query;

  if (!email) {
    return res.status(400).send({ error: 'Email is required' });
  }

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).send({ error: 'User not found' });
    }

    const userDetails = {
      username: user.username,
      email: user.email,
      userType: user.userType,
    };
    console.log(userDetails);
    res.send(userDetails);
  } catch (error) {
    res.status(500).send({ error: 'Error fetching user details' });
  }
});


module.exports = router;
