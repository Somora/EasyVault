# Embedded libraries

Replaced the local API-incompatible imitations with unmodified upstream sources on 2026-10-23.
Keep upstream library names, revision numbers, callback APIs, and storage layouts intact.

| Library | Embedded revision | Source |
| --- | --- | --- |
| LibStub | 2 | [Ace3](https://github.com/WoWUIDev/Ace3/blob/5a9344990ef9b437012e9d9e8531c3c6f88f4f8e/LibStub/LibStub.lua) |
| CallbackHandler-1.0 | 8 | [Ace3](https://github.com/WoWUIDev/Ace3/blob/5a9344990ef9b437012e9d9e8531c3c6f88f4f8e/CallbackHandler-1.0/CallbackHandler-1.0.lua) |
| LibDataBroker-1.1 | 4 | [tekkub/libdatabroker-1-1](https://github.com/tekkub/libdatabroker-1-1/blob/1a63ede0248c11aa1ee415187c1f9c9489ce3e02/LibDataBroker-1.1.lua) |
| LibDBIcon-1.0 | 57 | [WoWAce upstream](https://repos.wowace.com/wow/libdbicon-1-0/trunk/LibDBIcon-1.0/LibDBIcon-1.0.lua), repository revision 168 |

LibStub declares itself public domain in its source. CallbackHandler's Ace3 license is
included in `CallbackHandler-1.0/LICENSE.txt`. LibDataBroker credits Tekkub; its repository
does not include a separate license file. LibDBIcon credits Funkeh, Rabbit, and copystring;
its upstream TOC specifies `All Rights Reserved`. These third-party libraries retain
their upstream licensing and are not relicensed by EasyVault's root license.
