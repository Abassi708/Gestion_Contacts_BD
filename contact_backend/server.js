const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const Contact = require('./models/Contact');

const app = express();

// ========================
// MIDDLEWARES
// ========================
app.use(cors());
app.use(express.json());

// ========================
// CONNEXION MONGODB
// ========================
mongoose
  .connect('mongodb://127.0.0.1:27017/contacts_db')
  .then(() => console.log('MongoDB connecté'))
  .catch((err) => console.error('Erreur MongoDB:', err));

// ========================
// ROUTES API
// ========================

// GET : tous les contacts
app.get('/contacts', async (req, res) => {
  try {
    const contacts = await Contact.find();
    res.status(200).json(contacts);
  } catch (error) {
    res.status(500).json({ error: 'Erreur récupération contacts' });
  }
});

// POST : ajouter un contact
app.post('/contacts', async (req, res) => {
  try {
    const contact = new Contact({
      name: req.body.name,
      phone: req.body.phone,
      email: req.body.email,
      address: req.body.address,
      notes: req.body.notes,
    });

    const savedContact = await contact.save();
    res.status(201).json(savedContact);
  } catch (error) {
    res.status(400).json({ error: 'Erreur ajout contact' });
  }
});

// DELETE : supprimer un contact (CORRIGÉ ET SÉCURISÉ)
app.delete('/contacts/:id', async (req, res) => {
  const { id } = req.params;

  console.log('ID reçu pour suppression:', id);

  // Vérifier si l'ID est valide
  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({ error: 'ID invalide' });
  }

  try {
    const deletedContact = await Contact.findByIdAndDelete(
      new mongoose.Types.ObjectId(id)
    );

    if (!deletedContact) {
      return res.status(404).json({ error: 'Contact introuvable' });
    }

    return res.status(200).json({
      message: 'Contact supprimé avec succès',
      id: deletedContact._id,
    });
  } catch (error) {
    console.error('Erreur suppression:', error);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
});

// PUT : modifier un contact
app.put('/contacts/:id', async (req, res) => {
  const { id } = req.params;

  console.log('ID reçu pour modification:', id);

  // Vérifier si l'ID est valide
  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({ error: 'ID invalide' });
  }

  try {
    const updatedContact = await Contact.findByIdAndUpdate(
      new mongoose.Types.ObjectId(id),
      {
        name: req.body.name,
        phone: req.body.phone,
        email: req.body.email,
        address: req.body.address,
        notes: req.body.notes,
      },
      { new: true } // Retourne le document mis à jour
    );

    if (!updatedContact) {
      return res.status(404).json({ error: 'Contact introuvable' });
    }

    return res.status(200).json(updatedContact);
  } catch (error) {
    console.error('Erreur modification:', error);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ========================
// LANCER SERVEUR
// ========================
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`API lancée sur http://localhost:${PORT}`);
});

