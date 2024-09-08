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

namespace lnpopup {

template <size_t N>
struct base64_string : std::array<char, N> {
	consteval base64_string(const char (&input)[N]) : base64_string(input, std::make_index_sequence<N>{}) {}
	template <size_t... Is>
	consteval base64_string(const char (&input)[N], std::index_sequence<Is...>) : std::array<char, N>{ input[Is]... } {}
};

template <size_t N>
consteval const auto base64_encode(const char(&input)[N]) {
	constexpr char encoding_table[] =
	{
		'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
		'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
		'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
		'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
	};
	
	constexpr size_t out_len = 4 * (((N - 1) + 2) / 3) + 1;
	
	size_t in_len = N - 1;
	char output[out_len] {0};
	size_t i = 0;
	char *p = const_cast<char *>(output);
	
	for(i = 0; in_len > 2 && i < in_len - 2; i += 3)
	{
		*p++ = encoding_table[(input[i] >> 2) & 0x3F];
		*p++ = encoding_table[((input[i] & 0x3) << 4) | ((int)(input[i + 1] & 0xF0) >> 4)];
		*p++ = encoding_table[((input[i + 1] & 0xF) << 2) | ((int)(input[i + 2] & 0xC0) >> 6)];
		*p++ = encoding_table[input[i + 2] & 0x3F];
	}
	
	if(i < in_len)
	{
		*p++ = encoding_table[(input[i] >> 2) & 0x3F];
		if(i == (in_len - 1))
		{
			*p++ = encoding_table[((input[i] & 0x3) << 4)];
			*p++ = '=';
		}
		else
		{
			*p++ = encoding_table[((input[i] & 0x3) << 4) | ((int)(input[i + 1] & 0xF0) >> 4)];
			*p++ = encoding_table[((input[i + 1] & 0xF) << 2)];
		}
		*p++ = '=';
	}
	
	return base64_string<out_len>(output);
}

CF_INLINE
auto decode_hidden_string(auto encoded)
{
	return [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:@(encoded.data()) options:0] encoding:NSUTF8StringEncoding];
}

} //namespace lnpopup

#define LNPopupHiddenString(input) (lnpopup::decode_hidden_string(lnpopup::base64_encode("" input "")))
