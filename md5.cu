char *md5(const char *str, int length) {
	int n;
	MD5_CTX c;
	unsigned char digest[16];
	char *out = (char*) malloc(33 * sizeof(*out));

	MD5_Init(&c);

	while (length > 0) {
		if (length > 512) {
			MD5_Update(&c, str, 512);
		} else {
			MD5_Update(&c, str, length);
		}
		length -= 512;
		str += 512;
	}

	MD5_Final(digest, &c);

	for (n = 0; n < 16; ++n) {
		snprintf(&(out[n*2]), 16*2, "%02x", (unsigned int) digest[n]);
	}

	return out;
}
