#ifndef FIRESTOREMANAGER_H
#define FIRESTOREMANAGER_H

#include <Arduino.h>

// Pushes the given JSON payload (as a string) to Firestore.
void pushDataToFirestore(String jsonPayload);

#endif // FIRESTOREMANAGER_H
