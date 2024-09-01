//
//  _LNPopupBase64Utils.hh
//  LNPopupController
//
//  Created by Léo Natan on 1/9/24.
//  Copyright © 2024 Léo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <cstdlib>
#include <array>

CF_EXTERN_C_BEGIN

namespace lnpopup {

extern "C++"
template <size_t N>
struct base64_string : std::array<char, N> {
	consteval base64_string(const char (&input)[N]) : base64_string(input, std::make_index_sequence<N>{}) {}
	template <size_t... Is>
	consteval base64_string(const char (&input)[N], std::index_sequence<Is...>) : std::array<char, N>{ input[Is]... } {}
};

extern "C++"
template <size_t N>
consteval const base64_string<4 * (((N - 1) + 2) / 3) + 1> base64Encode(const char(&input)[N]) {
	constexpr char kEncodingTable[] =
	{
		'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
		'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
		'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
		'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
	};
	
	size_t in_len = N - 1;
	char output[4 * (((N - 1) + 2) / 3) + 1] {0};
	size_t i = 0;
	char *p = const_cast<char *>(output);
	
	for(i = 0; in_len > 2 && i < in_len - 2; i += 3)
	{
		*p++ = kEncodingTable[(input[i] >> 2) & 0x3F];
		*p++ = kEncodingTable[((input[i] & 0x3) << 4) | ((int)(input[i + 1] & 0xF0) >> 4)];
		*p++ = kEncodingTable[((input[i + 1] & 0xF) << 2) | ((int)(input[i + 2] & 0xC0) >> 6)];
		*p++ = kEncodingTable[input[i + 2] & 0x3F];
	}
	
	if(i < in_len)
	{
		*p++ = kEncodingTable[(input[i] >> 2) & 0x3F];
		if(i == (in_len - 1))
		{
			*p++ = kEncodingTable[((input[i] & 0x3) << 4)];
			*p++ = '=';
		}
		else
		{
			*p++ = kEncodingTable[((input[i] & 0x3) << 4) | ((int)(input[i + 1] & 0xF0) >> 4)];
			*p++ = kEncodingTable[((input[i + 1] & 0xF) << 2)];
		}
		*p++ = '=';
	}
	
	return base64_string<4 * (((N - 1) + 2) / 3) + 1>(output);
}

extern "C++"
template <typename T>
CF_INLINE
NSString* decodeHiddenString(T encoded)
{
	return [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:@(encoded.data()) options:0] encoding:NSUTF8StringEncoding];
}

} //namespace lnpopup

#define LNPopupHiddenString(input) lnpopup::decodeHiddenString(lnpopup::base64Encode("" input ""))

CF_EXTERN_C_END
