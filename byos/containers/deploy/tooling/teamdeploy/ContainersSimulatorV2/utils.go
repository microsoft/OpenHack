package main

func randomUser(m map[string]UserProfile) string {
	// ranges are randomly returned so this will
	// sudo randomly select a key
	for k := range m {
		return k
	}
	return ""
}

func randomTrip(m map[string]Trip) string {
	// ranges are randomly returned so this will
	// sudo randomly select a key
	for k := range m {
		return k
	}
	return ""
}

// https://stackoverflow.com/a/10485970/697126
func contains(s []string, e string) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}
