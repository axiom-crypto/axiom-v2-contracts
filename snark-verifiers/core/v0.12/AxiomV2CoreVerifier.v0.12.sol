// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract AxiomV2CoreVerifier {
    fallback(bytes calldata) external returns (bytes memory) {
        assembly ("memory-safe") {
            // Enforce that Solidity memory layout is respected
            let data := mload(0x40)
            if iszero(eq(data, 0x80)) { revert(0, 0) }

            let success := true
            let f_p := 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
            let f_q := 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001
            function validate_ec_point(x, y) -> valid {
                {
                    let x_lt_p := lt(x, 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47)
                    let y_lt_p := lt(y, 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47)
                    valid := and(x_lt_p, y_lt_p)
                }
                {
                    let y_square := mulmod(y, y, 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47)
                    let x_square := mulmod(x, x, 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47)
                    let x_cube :=
                        mulmod(x_square, x, 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47)
                    let x_cube_plus_3 :=
                        addmod(x_cube, 3, 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47)
                    let is_affine := eq(x_cube_plus_3, y_square)
                    valid := and(valid, is_affine)
                }
            }
            mstore(0xa0, mod(calldataload(0x0), f_q))
            mstore(0xc0, mod(calldataload(0x20), f_q))
            mstore(0xe0, mod(calldataload(0x40), f_q))
            mstore(0x100, mod(calldataload(0x60), f_q))
            mstore(0x120, mod(calldataload(0x80), f_q))
            mstore(0x140, mod(calldataload(0xa0), f_q))
            mstore(0x160, mod(calldataload(0xc0), f_q))
            mstore(0x180, mod(calldataload(0xe0), f_q))
            mstore(0x1a0, mod(calldataload(0x100), f_q))
            mstore(0x1c0, mod(calldataload(0x120), f_q))
            mstore(0x1e0, mod(calldataload(0x140), f_q))
            mstore(0x200, mod(calldataload(0x160), f_q))
            mstore(0x220, mod(calldataload(0x180), f_q))
            mstore(0x240, mod(calldataload(0x1a0), f_q))
            mstore(0x260, mod(calldataload(0x1c0), f_q))
            mstore(0x280, mod(calldataload(0x1e0), f_q))
            mstore(0x2a0, mod(calldataload(0x200), f_q))
            mstore(0x2c0, mod(calldataload(0x220), f_q))
            mstore(0x2e0, mod(calldataload(0x240), f_q))
            mstore(0x300, mod(calldataload(0x260), f_q))
            mstore(0x320, mod(calldataload(0x280), f_q))
            mstore(0x340, mod(calldataload(0x2a0), f_q))
            mstore(0x360, mod(calldataload(0x2c0), f_q))
            mstore(0x380, mod(calldataload(0x2e0), f_q))
            mstore(0x3a0, mod(calldataload(0x300), f_q))
            mstore(0x3c0, mod(calldataload(0x320), f_q))
            mstore(0x3e0, mod(calldataload(0x340), f_q))
            mstore(0x400, mod(calldataload(0x360), f_q))
            mstore(0x420, mod(calldataload(0x380), f_q))
            mstore(0x440, mod(calldataload(0x3a0), f_q))
            mstore(0x460, mod(calldataload(0x3c0), f_q))
            mstore(0x480, mod(calldataload(0x3e0), f_q))
            mstore(0x4a0, mod(calldataload(0x400), f_q))
            mstore(0x4c0, mod(calldataload(0x420), f_q))
            mstore(0x4e0, mod(calldataload(0x440), f_q))
            mstore(0x500, mod(calldataload(0x460), f_q))
            mstore(0x520, mod(calldataload(0x480), f_q))
            mstore(0x540, mod(calldataload(0x4a0), f_q))
            mstore(0x560, mod(calldataload(0x4c0), f_q))
            mstore(0x80, 21517744289616425937483314895361369060165378917266174309259926228310514355283)

            {
                let x := calldataload(0x4e0)
                mstore(0x580, x)
                let y := calldataload(0x500)
                mstore(0x5a0, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x5c0, keccak256(0x80, 1344))
            {
                let hash := mload(0x5c0)
                mstore(0x5e0, mod(hash, f_q))
                mstore(0x600, hash)
            }

            {
                let x := calldataload(0x520)
                mstore(0x620, x)
                let y := calldataload(0x540)
                mstore(0x640, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x560)
                mstore(0x660, x)
                let y := calldataload(0x580)
                mstore(0x680, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x6a0, keccak256(0x600, 160))
            {
                let hash := mload(0x6a0)
                mstore(0x6c0, mod(hash, f_q))
                mstore(0x6e0, hash)
            }
            mstore8(1792, 1)
            mstore(0x700, keccak256(0x6e0, 33))
            {
                let hash := mload(0x700)
                mstore(0x720, mod(hash, f_q))
                mstore(0x740, hash)
            }

            {
                let x := calldataload(0x5a0)
                mstore(0x760, x)
                let y := calldataload(0x5c0)
                mstore(0x780, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x5e0)
                mstore(0x7a0, x)
                let y := calldataload(0x600)
                mstore(0x7c0, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x620)
                mstore(0x7e0, x)
                let y := calldataload(0x640)
                mstore(0x800, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x820, keccak256(0x740, 224))
            {
                let hash := mload(0x820)
                mstore(0x840, mod(hash, f_q))
                mstore(0x860, hash)
            }

            {
                let x := calldataload(0x660)
                mstore(0x880, x)
                let y := calldataload(0x680)
                mstore(0x8a0, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x6a0)
                mstore(0x8c0, x)
                let y := calldataload(0x6c0)
                mstore(0x8e0, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x6e0)
                mstore(0x900, x)
                let y := calldataload(0x700)
                mstore(0x920, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x720)
                mstore(0x940, x)
                let y := calldataload(0x740)
                mstore(0x960, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x980, keccak256(0x860, 288))
            {
                let hash := mload(0x980)
                mstore(0x9a0, mod(hash, f_q))
                mstore(0x9c0, hash)
            }
            mstore(0x9e0, mod(calldataload(0x760), f_q))
            mstore(0xa00, mod(calldataload(0x780), f_q))
            mstore(0xa20, mod(calldataload(0x7a0), f_q))
            mstore(0xa40, mod(calldataload(0x7c0), f_q))
            mstore(0xa60, mod(calldataload(0x7e0), f_q))
            mstore(0xa80, mod(calldataload(0x800), f_q))
            mstore(0xaa0, mod(calldataload(0x820), f_q))
            mstore(0xac0, mod(calldataload(0x840), f_q))
            mstore(0xae0, mod(calldataload(0x860), f_q))
            mstore(0xb00, mod(calldataload(0x880), f_q))
            mstore(0xb20, mod(calldataload(0x8a0), f_q))
            mstore(0xb40, mod(calldataload(0x8c0), f_q))
            mstore(0xb60, mod(calldataload(0x8e0), f_q))
            mstore(0xb80, mod(calldataload(0x900), f_q))
            mstore(0xba0, mod(calldataload(0x920), f_q))
            mstore(0xbc0, mod(calldataload(0x940), f_q))
            mstore(0xbe0, mod(calldataload(0x960), f_q))
            mstore(0xc00, mod(calldataload(0x980), f_q))
            mstore(0xc20, mod(calldataload(0x9a0), f_q))
            mstore(0xc40, keccak256(0x9c0, 640))
            {
                let hash := mload(0xc40)
                mstore(0xc60, mod(hash, f_q))
                mstore(0xc80, hash)
            }
            mstore8(3232, 1)
            mstore(0xca0, keccak256(0xc80, 33))
            {
                let hash := mload(0xca0)
                mstore(0xcc0, mod(hash, f_q))
                mstore(0xce0, hash)
            }

            {
                let x := calldataload(0x9c0)
                mstore(0xd00, x)
                let y := calldataload(0x9e0)
                mstore(0xd20, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0xd40, keccak256(0xce0, 96))
            {
                let hash := mload(0xd40)
                mstore(0xd60, mod(hash, f_q))
                mstore(0xd80, hash)
            }

            {
                let x := calldataload(0xa00)
                mstore(0xda0, x)
                let y := calldataload(0xa20)
                mstore(0xdc0, y)
                success := and(validate_ec_point(x, y), success)
            }
            {
                let x := mload(0xa0)
                x := add(x, shl(88, mload(0xc0)))
                x := add(x, shl(176, mload(0xe0)))
                mstore(3552, x)
                let y := mload(0x100)
                y := add(y, shl(88, mload(0x120)))
                y := add(y, shl(176, mload(0x140)))
                mstore(3584, y)

                success := and(validate_ec_point(x, y), success)
            }
            {
                let x := mload(0x160)
                x := add(x, shl(88, mload(0x180)))
                x := add(x, shl(176, mload(0x1a0)))
                mstore(3616, x)
                let y := mload(0x1c0)
                y := add(y, shl(88, mload(0x1e0)))
                y := add(y, shl(176, mload(0x200)))
                mstore(3648, y)

                success := and(validate_ec_point(x, y), success)
            }
            mstore(0xe60, mulmod(mload(0x9a0), mload(0x9a0), f_q))
            mstore(0xe80, mulmod(mload(0xe60), mload(0xe60), f_q))
            mstore(0xea0, mulmod(mload(0xe80), mload(0xe80), f_q))
            mstore(0xec0, mulmod(mload(0xea0), mload(0xea0), f_q))
            mstore(0xee0, mulmod(mload(0xec0), mload(0xec0), f_q))
            mstore(0xf00, mulmod(mload(0xee0), mload(0xee0), f_q))
            mstore(0xf20, mulmod(mload(0xf00), mload(0xf00), f_q))
            mstore(0xf40, mulmod(mload(0xf20), mload(0xf20), f_q))
            mstore(0xf60, mulmod(mload(0xf40), mload(0xf40), f_q))
            mstore(0xf80, mulmod(mload(0xf60), mload(0xf60), f_q))
            mstore(0xfa0, mulmod(mload(0xf80), mload(0xf80), f_q))
            mstore(0xfc0, mulmod(mload(0xfa0), mload(0xfa0), f_q))
            mstore(0xfe0, mulmod(mload(0xfc0), mload(0xfc0), f_q))
            mstore(0x1000, mulmod(mload(0xfe0), mload(0xfe0), f_q))
            mstore(0x1020, mulmod(mload(0x1000), mload(0x1000), f_q))
            mstore(0x1040, mulmod(mload(0x1020), mload(0x1020), f_q))
            mstore(0x1060, mulmod(mload(0x1040), mload(0x1040), f_q))
            mstore(0x1080, mulmod(mload(0x1060), mload(0x1060), f_q))
            mstore(0x10a0, mulmod(mload(0x1080), mload(0x1080), f_q))
            mstore(0x10c0, mulmod(mload(0x10a0), mload(0x10a0), f_q))
            mstore(0x10e0, mulmod(mload(0x10c0), mload(0x10c0), f_q))
            mstore(0x1100, mulmod(mload(0x10e0), mload(0x10e0), f_q))
            mstore(0x1120, mulmod(mload(0x1100), mload(0x1100), f_q))
            mstore(
                0x1140,
                addmod(
                    mload(0x1120), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q
                )
            )
            mstore(
                0x1160,
                mulmod(
                    mload(0x1140), 21888240262557392955334514970720457388010314637169927192662615958087340972065, f_q
                )
            )
            mstore(
                0x1180,
                mulmod(mload(0x1160), 4506835738822104338668100540817374747935106310012997856968187171738630203507, f_q)
            )
            mstore(
                0x11a0,
                addmod(mload(0x9a0), 17381407133017170883578305204439900340613258090403036486730017014837178292110, f_q)
            )
            mstore(
                0x11c0,
                mulmod(
                    mload(0x1160), 21710372849001950800533397158415938114909991150039389063546734567764856596059, f_q
                )
            )
            mstore(
                0x11e0,
                addmod(mload(0x9a0), 177870022837324421713008586841336973638373250376645280151469618810951899558, f_q)
            )
            mstore(
                0x1200,
                mulmod(mload(0x1160), 1887003188133998471169152042388914354640772748308168868301418279904560637395, f_q)
            )
            mstore(
                0x1220,
                addmod(mload(0x9a0), 20001239683705276751077253702868360733907591652107865475396785906671247858222, f_q)
            )
            mstore(
                0x1240,
                mulmod(mload(0x1160), 2785514556381676080176937710880804108647911392478702105860685610379369825016, f_q)
            )
            mstore(
                0x1260,
                addmod(mload(0x9a0), 19102728315457599142069468034376470979900453007937332237837518576196438670601, f_q)
            )
            mstore(
                0x1280,
                mulmod(
                    mload(0x1160), 14655294445420895451632927078981340937842238432098198055057679026789553137428, f_q
                )
            )
            mstore(
                0x12a0,
                addmod(mload(0x9a0), 7232948426418379770613478666275934150706125968317836288640525159786255358189, f_q)
            )
            mstore(
                0x12c0,
                mulmod(mload(0x1160), 8734126352828345679573237859165904705806588461301144420590422589042130041188, f_q)
            )
            mstore(
                0x12e0,
                addmod(mload(0x9a0), 13154116519010929542673167886091370382741775939114889923107781597533678454429, f_q)
            )
            mstore(
                0x1300,
                mulmod(mload(0x1160), 9741553891420464328295280489650144566903017206473301385034033384879943874347, f_q)
            )
            mstore(
                0x1320,
                addmod(mload(0x9a0), 12146688980418810893951125255607130521645347193942732958664170801695864621270, f_q)
            )
            mstore(0x1340, mulmod(mload(0x1160), 1, f_q))
            mstore(
                0x1360,
                addmod(mload(0x9a0), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q)
            )
            mstore(
                0x1380,
                mulmod(mload(0x1160), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            mstore(
                0x13a0,
                addmod(mload(0x9a0), 13513867906530865119835332133273263211836799082674232843258448413103731898270, f_q)
            )
            mstore(
                0x13c0,
                mulmod(
                    mload(0x1160), 11211301017135681023579411905410872569206244553457844956874280139879520583390, f_q
                )
            )
            mstore(
                0x13e0,
                addmod(mload(0x9a0), 10676941854703594198666993839846402519342119846958189386823924046696287912227, f_q)
            )
            mstore(
                0x1400,
                mulmod(mload(0x1160), 3615478808282855240548287271348143516886772452944084747768312988864436725401, f_q)
            )
            mstore(
                0x1420,
                addmod(mload(0x9a0), 18272764063556419981698118473909131571661591947471949595929891197711371770216, f_q)
            )
            mstore(
                0x1440,
                mulmod(mload(0x1160), 1426404432721484388505361748317961535523355871255605456897797744433766488507, f_q)
            )
            mstore(
                0x1460,
                addmod(mload(0x9a0), 20461838439117790833741043996939313553025008529160428886800406442142042007110, f_q)
            )
            mstore(
                0x1480,
                mulmod(mload(0x1160), 216092043779272773661818549620449970334216366264741118684015851799902419467, f_q)
            )
            mstore(
                0x14a0,
                addmod(mload(0x9a0), 21672150828060002448584587195636825118214148034151293225014188334775906076150, f_q)
            )
            mstore(
                0x14c0,
                mulmod(
                    mload(0x1160), 12619617507853212586156872920672483948819476989779550311307282715684870266992, f_q
                )
            )
            mstore(
                0x14e0,
                addmod(mload(0x9a0), 9268625363986062636089532824584791139728887410636484032390921470890938228625, f_q)
            )
            mstore(
                0x1500,
                mulmod(
                    mload(0x1160), 18610195890048912503953886742825279624920778288956610528523679659246523534888, f_q
                )
            )
            mstore(
                0x1520,
                addmod(mload(0x9a0), 3278046981790362718292519002431995463627586111459423815174524527329284960729, f_q)
            )
            mstore(
                0x1540,
                mulmod(
                    mload(0x1160), 19032961837237948602743626455740240236231119053033140765040043513661803148152, f_q
                )
            )
            mstore(
                0x1560,
                addmod(mload(0x9a0), 2855281034601326619502779289517034852317245347382893578658160672914005347465, f_q)
            )
            mstore(
                0x1580,
                mulmod(
                    mload(0x1160), 14875928112196239563830800280253496262679717528621719058794366823499719730250, f_q
                )
            )
            mstore(
                0x15a0,
                addmod(mload(0x9a0), 7012314759643035658415605465003778825868646871794315284903837363076088765367, f_q)
            )
            mstore(
                0x15c0,
                mulmod(mload(0x1160), 915149353520972163646494413843788069594022902357002628455555785223409501882, f_q)
            )
            mstore(
                0x15e0,
                addmod(mload(0x9a0), 20973093518318303058599911331413487018954341498059031715242648401352398993735, f_q)
            )
            mstore(
                0x1600,
                mulmod(mload(0x1160), 5522161504810533295870699551020523636289972223872138525048055197429246400245, f_q)
            )
            mstore(
                0x1620,
                addmod(mload(0x9a0), 16366081367028741926375706194236751452258392176543895818650148989146562095372, f_q)
            )
            mstore(
                0x1640,
                mulmod(mload(0x1160), 3766081621734395783232337525162072736827576297943013392955872170138036189193, f_q)
            )
            mstore(
                0x1660,
                addmod(mload(0x9a0), 18122161250104879439014068220095202351720788102473020950742332016437772306424, f_q)
            )
            mstore(
                0x1680,
                mulmod(mload(0x1160), 9100833993744738801214480881117348002768153232283708533639316963648253510584, f_q)
            )
            mstore(
                0x16a0,
                addmod(mload(0x9a0), 12787408878094536421031924864139927085780211168132325810058887222927554985033, f_q)
            )
            mstore(
                0x16c0,
                mulmod(mload(0x1160), 4245441013247250116003069945606352967193023389718465410501109428393342802981, f_q)
            )
            mstore(
                0x16e0,
                addmod(mload(0x9a0), 17642801858592025106243335799650922121355341010697568933197094758182465692636, f_q)
            )
            mstore(
                0x1700,
                mulmod(mload(0x1160), 6132660129994545119218258312491950835441607143741804980633129304664017206141, f_q)
            )
            mstore(
                0x1720,
                addmod(mload(0x9a0), 15755582741844730103028147432765324253106757256674229363065074881911791289476, f_q)
            )
            mstore(
                0x1740,
                mulmod(mload(0x1160), 5854133144571823792863860130267644613802765696134002830362054821530146160770, f_q)
            )
            mstore(
                0x1760,
                addmod(mload(0x9a0), 16034109727267451429382545614989630474745598704282031513336149365045662334847, f_q)
            )
            mstore(
                0x1780,
                mulmod(mload(0x1160), 515148244606945972463850631189471072103916690263705052318085725998468254533, f_q)
            )
            mstore(
                0x17a0,
                addmod(mload(0x9a0), 21373094627232329249782555114067804016444447710152329291380118460577340241084, f_q)
            )
            mstore(
                0x17c0,
                mulmod(mload(0x1160), 5980488956150442207659150513163747165544364597008566989111579977672498964212, f_q)
            )
            mstore(
                0x17e0,
                addmod(mload(0x9a0), 15907753915688833014587255232093527923003999803407467354586624208903309531405, f_q)
            )
            mstore(
                0x1800,
                mulmod(mload(0x1160), 5223738580615264174925218065001555728265216895679471490312087802465486318994, f_q)
            )
            mstore(
                0x1820,
                addmod(mload(0x9a0), 16664504291224011047321187680255719360283147504736562853386116384110322176623, f_q)
            )
            mstore(
                0x1840,
                mulmod(
                    mload(0x1160), 14557038802599140430182096396825290815503940951075961210638273254419942783582, f_q
                )
            )
            mstore(
                0x1860,
                addmod(mload(0x9a0), 7331204069240134792064309348431984273044423449340073133059930932155865712035, f_q)
            )
            mstore(
                0x1880,
                mulmod(
                    mload(0x1160), 16976236069879939850923145256911338076234942200101755618884183331004076579046, f_q
                )
            )
            mstore(
                0x18a0,
                addmod(mload(0x9a0), 4912006801959335371323260488345937012313422200314278724814020855571731916571, f_q)
            )
            mstore(
                0x18c0,
                mulmod(
                    mload(0x1160), 13553911191894110065493137367144919847521088405945523452288398666974237857208, f_q
                )
            )
            mstore(
                0x18e0,
                addmod(mload(0x9a0), 8334331679945165156753268378112355241027275994470510891409805519601570638409, f_q)
            )
            mstore(
                0x1900,
                mulmod(
                    mload(0x1160), 12222687719926148270818604386979005738180875192307070468454582955273533101023, f_q
                )
            )
            mstore(
                0x1920,
                addmod(mload(0x9a0), 9665555151913126951427801358278269350367489208108963875243621231302275394594, f_q)
            )
            mstore(
                0x1940,
                mulmod(mload(0x1160), 9697063347556872083384215826199993067635178715531258559890418744774301211662, f_q)
            )
            mstore(
                0x1960,
                addmod(mload(0x9a0), 12191179524282403138862189919057282020913185684884775783807785441801507283955, f_q)
            )
            mstore(
                0x1980,
                mulmod(
                    mload(0x1160), 13783318220968413117070077848579881425001701814458176881760898225529300547844, f_q
                )
            )
            mstore(
                0x19a0,
                addmod(mload(0x9a0), 8104924650870862105176327896677393663546662585957857461937305961046507947773, f_q)
            )
            mstore(
                0x19c0,
                mulmod(
                    mload(0x1160), 10807735674816066981985242612061336605021639643453679977988966079770672437131, f_q
                )
            )
            mstore(
                0x19e0,
                addmod(mload(0x9a0), 11080507197023208240261163133195938483526724756962354365709238106805136058486, f_q)
            )
            mstore(
                0x1a00,
                mulmod(
                    mload(0x1160), 15487660954688013862248478071816391715224351867581977083810729441220383572585, f_q
                )
            )
            mstore(
                0x1a20,
                addmod(mload(0x9a0), 6400581917151261359997927673440883373324012532834057259887474745355424923032, f_q)
            )
            mstore(
                0x1a40,
                mulmod(
                    mload(0x1160), 12459868075641381822485233712013080087763946065665469821362892189399541605692, f_q
                )
            )
            mstore(
                0x1a60,
                addmod(mload(0x9a0), 9428374796197893399761172033244195000784418334750564522335311997176266889925, f_q)
            )
            mstore(
                0x1a80,
                mulmod(
                    mload(0x1160), 12562571400845953139885120066983392294851269266041089223701347829190217414825, f_q
                )
            )
            mstore(
                0x1aa0,
                addmod(mload(0x9a0), 9325671470993322082361285678273882793697095134374945119996856357385591080792, f_q)
            )
            mstore(
                0x1ac0,
                mulmod(
                    mload(0x1160), 16038300751658239075779628684257016433412502747804121525056508685985277092575, f_q
                )
            )
            mstore(
                0x1ae0,
                addmod(mload(0x9a0), 5849942120181036146466777061000258655135861652611912818641695500590531403042, f_q)
            )
            mstore(
                0x1b00,
                mulmod(
                    mload(0x1160), 17665522928519859765452767154433594409738037332395989540221744312194874941704, f_q
                )
            )
            mstore(
                0x1b20,
                addmod(mload(0x9a0), 4222719943319415456793638590823680678810327068020044803476459874380933553913, f_q)
            )
            mstore(
                0x1b40,
                mulmod(mload(0x1160), 6955697244493336113861667751840378876927906302623587437721024018233754910398, f_q)
            )
            mstore(
                0x1b60,
                addmod(mload(0x9a0), 14932545627345939108384737993416896211620458097792446905977180168342053585219, f_q)
            )
            mstore(
                0x1b80,
                mulmod(mload(0x1160), 1918679275621049296283934091410967415474987212511681231948800935495808101054, f_q)
            )
            mstore(
                0x1ba0,
                addmod(mload(0x9a0), 19969563596218225925962471653846307673073377187904353111749403251080000394563, f_q)
            )
            mstore(
                0x1bc0,
                mulmod(
                    mload(0x1160), 13498745591877810872211159461644682954739332524336278910448604883789771736885, f_q
                )
            )
            mstore(
                0x1be0,
                addmod(mload(0x9a0), 8389497279961464350035246283612592133809031876079755433249599302786036758732, f_q)
            )
            mstore(
                0x1c00,
                mulmod(mload(0x1160), 6604851689411953560355663038203889299997924520355363678860500374111951937637, f_q)
            )
            mstore(
                0x1c20,
                addmod(mload(0x9a0), 15283391182427321661890742707053385788550439880060670664837703812463856557980, f_q)
            )
            mstore(
                0x1c40,
                mulmod(
                    mload(0x1160), 20345677989844117909528750049476969581182118546166966482506114734614108237981, f_q
                )
            )
            mstore(
                0x1c60,
                addmod(mload(0x9a0), 1542564881995157312717655695780305507366245854249067861192089451961700257636, f_q)
            )
            mstore(
                0x1c80,
                mulmod(
                    mload(0x1160), 11244009323710436498447061620026171700033960328162115124806024297270121927878, f_q
                )
            )
            mstore(
                0x1ca0,
                addmod(mload(0x9a0), 10644233548128838723799344125231103388514404072253919218892179889305686567739, f_q)
            )
            mstore(
                0x1cc0,
                mulmod(mload(0x1160), 790608022292213379425324383664216541739009722347092850716054055768832299157, f_q)
            )
            mstore(
                0x1ce0,
                addmod(mload(0x9a0), 21097634849547061842821081361593058546809354678068941492982150130806976196460, f_q)
            )
            {
                let prod := mload(0x11a0)

                prod := mulmod(mload(0x11e0), prod, f_q)
                mstore(0x1d00, prod)

                prod := mulmod(mload(0x1220), prod, f_q)
                mstore(0x1d20, prod)

                prod := mulmod(mload(0x1260), prod, f_q)
                mstore(0x1d40, prod)

                prod := mulmod(mload(0x12a0), prod, f_q)
                mstore(0x1d60, prod)

                prod := mulmod(mload(0x12e0), prod, f_q)
                mstore(0x1d80, prod)

                prod := mulmod(mload(0x1320), prod, f_q)
                mstore(0x1da0, prod)

                prod := mulmod(mload(0x1360), prod, f_q)
                mstore(0x1dc0, prod)

                prod := mulmod(mload(0x13a0), prod, f_q)
                mstore(0x1de0, prod)

                prod := mulmod(mload(0x13e0), prod, f_q)
                mstore(0x1e00, prod)

                prod := mulmod(mload(0x1420), prod, f_q)
                mstore(0x1e20, prod)

                prod := mulmod(mload(0x1460), prod, f_q)
                mstore(0x1e40, prod)

                prod := mulmod(mload(0x14a0), prod, f_q)
                mstore(0x1e60, prod)

                prod := mulmod(mload(0x14e0), prod, f_q)
                mstore(0x1e80, prod)

                prod := mulmod(mload(0x1520), prod, f_q)
                mstore(0x1ea0, prod)

                prod := mulmod(mload(0x1560), prod, f_q)
                mstore(0x1ec0, prod)

                prod := mulmod(mload(0x15a0), prod, f_q)
                mstore(0x1ee0, prod)

                prod := mulmod(mload(0x15e0), prod, f_q)
                mstore(0x1f00, prod)

                prod := mulmod(mload(0x1620), prod, f_q)
                mstore(0x1f20, prod)

                prod := mulmod(mload(0x1660), prod, f_q)
                mstore(0x1f40, prod)

                prod := mulmod(mload(0x16a0), prod, f_q)
                mstore(0x1f60, prod)

                prod := mulmod(mload(0x16e0), prod, f_q)
                mstore(0x1f80, prod)

                prod := mulmod(mload(0x1720), prod, f_q)
                mstore(0x1fa0, prod)

                prod := mulmod(mload(0x1760), prod, f_q)
                mstore(0x1fc0, prod)

                prod := mulmod(mload(0x17a0), prod, f_q)
                mstore(0x1fe0, prod)

                prod := mulmod(mload(0x17e0), prod, f_q)
                mstore(0x2000, prod)

                prod := mulmod(mload(0x1820), prod, f_q)
                mstore(0x2020, prod)

                prod := mulmod(mload(0x1860), prod, f_q)
                mstore(0x2040, prod)

                prod := mulmod(mload(0x18a0), prod, f_q)
                mstore(0x2060, prod)

                prod := mulmod(mload(0x18e0), prod, f_q)
                mstore(0x2080, prod)

                prod := mulmod(mload(0x1920), prod, f_q)
                mstore(0x20a0, prod)

                prod := mulmod(mload(0x1960), prod, f_q)
                mstore(0x20c0, prod)

                prod := mulmod(mload(0x19a0), prod, f_q)
                mstore(0x20e0, prod)

                prod := mulmod(mload(0x19e0), prod, f_q)
                mstore(0x2100, prod)

                prod := mulmod(mload(0x1a20), prod, f_q)
                mstore(0x2120, prod)

                prod := mulmod(mload(0x1a60), prod, f_q)
                mstore(0x2140, prod)

                prod := mulmod(mload(0x1aa0), prod, f_q)
                mstore(0x2160, prod)

                prod := mulmod(mload(0x1ae0), prod, f_q)
                mstore(0x2180, prod)

                prod := mulmod(mload(0x1b20), prod, f_q)
                mstore(0x21a0, prod)

                prod := mulmod(mload(0x1b60), prod, f_q)
                mstore(0x21c0, prod)

                prod := mulmod(mload(0x1ba0), prod, f_q)
                mstore(0x21e0, prod)

                prod := mulmod(mload(0x1be0), prod, f_q)
                mstore(0x2200, prod)

                prod := mulmod(mload(0x1c20), prod, f_q)
                mstore(0x2220, prod)

                prod := mulmod(mload(0x1c60), prod, f_q)
                mstore(0x2240, prod)

                prod := mulmod(mload(0x1ca0), prod, f_q)
                mstore(0x2260, prod)

                prod := mulmod(mload(0x1ce0), prod, f_q)
                mstore(0x2280, prod)

                prod := mulmod(mload(0x1140), prod, f_q)
                mstore(0x22a0, prod)
            }
            mstore(0x22e0, 32)
            mstore(0x2300, 32)
            mstore(0x2320, 32)
            mstore(0x2340, mload(0x22a0))
            mstore(0x2360, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
            mstore(0x2380, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
            success := and(eq(staticcall(gas(), 0x5, 0x22e0, 0xc0, 0x22c0, 0x20), 1), success)
            {
                let inv := mload(0x22c0)
                let v

                v := mload(0x1140)
                mstore(4416, mulmod(mload(0x2280), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1ce0)
                mstore(7392, mulmod(mload(0x2260), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1ca0)
                mstore(7328, mulmod(mload(0x2240), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1c60)
                mstore(7264, mulmod(mload(0x2220), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1c20)
                mstore(7200, mulmod(mload(0x2200), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1be0)
                mstore(7136, mulmod(mload(0x21e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1ba0)
                mstore(7072, mulmod(mload(0x21c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1b60)
                mstore(7008, mulmod(mload(0x21a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1b20)
                mstore(6944, mulmod(mload(0x2180), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1ae0)
                mstore(6880, mulmod(mload(0x2160), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1aa0)
                mstore(6816, mulmod(mload(0x2140), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1a60)
                mstore(6752, mulmod(mload(0x2120), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1a20)
                mstore(6688, mulmod(mload(0x2100), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x19e0)
                mstore(6624, mulmod(mload(0x20e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x19a0)
                mstore(6560, mulmod(mload(0x20c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1960)
                mstore(6496, mulmod(mload(0x20a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1920)
                mstore(6432, mulmod(mload(0x2080), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x18e0)
                mstore(6368, mulmod(mload(0x2060), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x18a0)
                mstore(6304, mulmod(mload(0x2040), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1860)
                mstore(6240, mulmod(mload(0x2020), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1820)
                mstore(6176, mulmod(mload(0x2000), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x17e0)
                mstore(6112, mulmod(mload(0x1fe0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x17a0)
                mstore(6048, mulmod(mload(0x1fc0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1760)
                mstore(5984, mulmod(mload(0x1fa0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1720)
                mstore(5920, mulmod(mload(0x1f80), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x16e0)
                mstore(5856, mulmod(mload(0x1f60), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x16a0)
                mstore(5792, mulmod(mload(0x1f40), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1660)
                mstore(5728, mulmod(mload(0x1f20), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1620)
                mstore(5664, mulmod(mload(0x1f00), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x15e0)
                mstore(5600, mulmod(mload(0x1ee0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x15a0)
                mstore(5536, mulmod(mload(0x1ec0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1560)
                mstore(5472, mulmod(mload(0x1ea0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1520)
                mstore(5408, mulmod(mload(0x1e80), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x14e0)
                mstore(5344, mulmod(mload(0x1e60), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x14a0)
                mstore(5280, mulmod(mload(0x1e40), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1460)
                mstore(5216, mulmod(mload(0x1e20), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1420)
                mstore(5152, mulmod(mload(0x1e00), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x13e0)
                mstore(5088, mulmod(mload(0x1de0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x13a0)
                mstore(5024, mulmod(mload(0x1dc0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1360)
                mstore(4960, mulmod(mload(0x1da0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1320)
                mstore(4896, mulmod(mload(0x1d80), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x12e0)
                mstore(4832, mulmod(mload(0x1d60), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x12a0)
                mstore(4768, mulmod(mload(0x1d40), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1260)
                mstore(4704, mulmod(mload(0x1d20), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1220)
                mstore(4640, mulmod(mload(0x1d00), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x11e0)
                mstore(4576, mulmod(mload(0x11a0), inv, f_q))
                inv := mulmod(v, inv, f_q)
                mstore(0x11a0, inv)
            }
            mstore(0x23a0, mulmod(mload(0x1180), mload(0x11a0), f_q))
            mstore(0x23c0, mulmod(mload(0x11c0), mload(0x11e0), f_q))
            mstore(0x23e0, mulmod(mload(0x1200), mload(0x1220), f_q))
            mstore(0x2400, mulmod(mload(0x1240), mload(0x1260), f_q))
            mstore(0x2420, mulmod(mload(0x1280), mload(0x12a0), f_q))
            mstore(0x2440, mulmod(mload(0x12c0), mload(0x12e0), f_q))
            mstore(0x2460, mulmod(mload(0x1300), mload(0x1320), f_q))
            mstore(0x2480, mulmod(mload(0x1340), mload(0x1360), f_q))
            mstore(0x24a0, mulmod(mload(0x1380), mload(0x13a0), f_q))
            mstore(0x24c0, mulmod(mload(0x13c0), mload(0x13e0), f_q))
            mstore(0x24e0, mulmod(mload(0x1400), mload(0x1420), f_q))
            mstore(0x2500, mulmod(mload(0x1440), mload(0x1460), f_q))
            mstore(0x2520, mulmod(mload(0x1480), mload(0x14a0), f_q))
            mstore(0x2540, mulmod(mload(0x14c0), mload(0x14e0), f_q))
            mstore(0x2560, mulmod(mload(0x1500), mload(0x1520), f_q))
            mstore(0x2580, mulmod(mload(0x1540), mload(0x1560), f_q))
            mstore(0x25a0, mulmod(mload(0x1580), mload(0x15a0), f_q))
            mstore(0x25c0, mulmod(mload(0x15c0), mload(0x15e0), f_q))
            mstore(0x25e0, mulmod(mload(0x1600), mload(0x1620), f_q))
            mstore(0x2600, mulmod(mload(0x1640), mload(0x1660), f_q))
            mstore(0x2620, mulmod(mload(0x1680), mload(0x16a0), f_q))
            mstore(0x2640, mulmod(mload(0x16c0), mload(0x16e0), f_q))
            mstore(0x2660, mulmod(mload(0x1700), mload(0x1720), f_q))
            mstore(0x2680, mulmod(mload(0x1740), mload(0x1760), f_q))
            mstore(0x26a0, mulmod(mload(0x1780), mload(0x17a0), f_q))
            mstore(0x26c0, mulmod(mload(0x17c0), mload(0x17e0), f_q))
            mstore(0x26e0, mulmod(mload(0x1800), mload(0x1820), f_q))
            mstore(0x2700, mulmod(mload(0x1840), mload(0x1860), f_q))
            mstore(0x2720, mulmod(mload(0x1880), mload(0x18a0), f_q))
            mstore(0x2740, mulmod(mload(0x18c0), mload(0x18e0), f_q))
            mstore(0x2760, mulmod(mload(0x1900), mload(0x1920), f_q))
            mstore(0x2780, mulmod(mload(0x1940), mload(0x1960), f_q))
            mstore(0x27a0, mulmod(mload(0x1980), mload(0x19a0), f_q))
            mstore(0x27c0, mulmod(mload(0x19c0), mload(0x19e0), f_q))
            mstore(0x27e0, mulmod(mload(0x1a00), mload(0x1a20), f_q))
            mstore(0x2800, mulmod(mload(0x1a40), mload(0x1a60), f_q))
            mstore(0x2820, mulmod(mload(0x1a80), mload(0x1aa0), f_q))
            mstore(0x2840, mulmod(mload(0x1ac0), mload(0x1ae0), f_q))
            mstore(0x2860, mulmod(mload(0x1b00), mload(0x1b20), f_q))
            mstore(0x2880, mulmod(mload(0x1b40), mload(0x1b60), f_q))
            mstore(0x28a0, mulmod(mload(0x1b80), mload(0x1ba0), f_q))
            mstore(0x28c0, mulmod(mload(0x1bc0), mload(0x1be0), f_q))
            mstore(0x28e0, mulmod(mload(0x1c00), mload(0x1c20), f_q))
            mstore(0x2900, mulmod(mload(0x1c40), mload(0x1c60), f_q))
            mstore(0x2920, mulmod(mload(0x1c80), mload(0x1ca0), f_q))
            mstore(0x2940, mulmod(mload(0x1cc0), mload(0x1ce0), f_q))
            {
                let result := mulmod(mload(0x2480), mload(0xa0), f_q)
                result := addmod(mulmod(mload(0x24a0), mload(0xc0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x24c0), mload(0xe0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x24e0), mload(0x100), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2500), mload(0x120), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2520), mload(0x140), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2540), mload(0x160), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2560), mload(0x180), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2580), mload(0x1a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x25a0), mload(0x1c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x25c0), mload(0x1e0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x25e0), mload(0x200), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2600), mload(0x220), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2620), mload(0x240), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2640), mload(0x260), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2660), mload(0x280), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2680), mload(0x2a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x26a0), mload(0x2c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x26c0), mload(0x2e0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x26e0), mload(0x300), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2700), mload(0x320), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2720), mload(0x340), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2740), mload(0x360), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2760), mload(0x380), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2780), mload(0x3a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x27a0), mload(0x3c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x27c0), mload(0x3e0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x27e0), mload(0x400), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2800), mload(0x420), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2820), mload(0x440), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2840), mload(0x460), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2860), mload(0x480), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2880), mload(0x4a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x28a0), mload(0x4c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x28c0), mload(0x4e0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x28e0), mload(0x500), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2900), mload(0x520), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2920), mload(0x540), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2940), mload(0x560), f_q), result, f_q)
                mstore(10592, result)
            }
            mstore(0x2980, mulmod(mload(0xa20), mload(0xa00), f_q))
            mstore(0x29a0, addmod(mload(0x9e0), mload(0x2980), f_q))
            mstore(0x29c0, addmod(mload(0x29a0), sub(f_q, mload(0xa40)), f_q))
            mstore(0x29e0, mulmod(mload(0x29c0), mload(0xaa0), f_q))
            mstore(0x2a00, mulmod(mload(0x840), mload(0x29e0), f_q))
            mstore(0x2a20, addmod(1, sub(f_q, mload(0xb60)), f_q))
            mstore(0x2a40, mulmod(mload(0x2a20), mload(0x2480), f_q))
            mstore(0x2a60, addmod(mload(0x2a00), mload(0x2a40), f_q))
            mstore(0x2a80, mulmod(mload(0x840), mload(0x2a60), f_q))
            mstore(0x2aa0, mulmod(mload(0xb60), mload(0xb60), f_q))
            mstore(0x2ac0, addmod(mload(0x2aa0), sub(f_q, mload(0xb60)), f_q))
            mstore(0x2ae0, mulmod(mload(0x2ac0), mload(0x23a0), f_q))
            mstore(0x2b00, addmod(mload(0x2a80), mload(0x2ae0), f_q))
            mstore(0x2b20, mulmod(mload(0x840), mload(0x2b00), f_q))
            mstore(0x2b40, addmod(1, sub(f_q, mload(0x23a0)), f_q))
            mstore(0x2b60, addmod(mload(0x23c0), mload(0x23e0), f_q))
            mstore(0x2b80, addmod(mload(0x2b60), mload(0x2400), f_q))
            mstore(0x2ba0, addmod(mload(0x2b80), mload(0x2420), f_q))
            mstore(0x2bc0, addmod(mload(0x2ba0), mload(0x2440), f_q))
            mstore(0x2be0, addmod(mload(0x2bc0), mload(0x2460), f_q))
            mstore(0x2c00, addmod(mload(0x2b40), sub(f_q, mload(0x2be0)), f_q))
            mstore(0x2c20, mulmod(mload(0xb00), mload(0x6c0), f_q))
            mstore(0x2c40, addmod(mload(0xa60), mload(0x2c20), f_q))
            mstore(0x2c60, addmod(mload(0x2c40), mload(0x720), f_q))
            mstore(0x2c80, mulmod(mload(0xb20), mload(0x6c0), f_q))
            mstore(0x2ca0, addmod(mload(0x9e0), mload(0x2c80), f_q))
            mstore(0x2cc0, addmod(mload(0x2ca0), mload(0x720), f_q))
            mstore(0x2ce0, mulmod(mload(0x2cc0), mload(0x2c60), f_q))
            mstore(0x2d00, mulmod(mload(0xb40), mload(0x6c0), f_q))
            mstore(0x2d20, addmod(mload(0x2960), mload(0x2d00), f_q))
            mstore(0x2d40, addmod(mload(0x2d20), mload(0x720), f_q))
            mstore(0x2d60, mulmod(mload(0x2d40), mload(0x2ce0), f_q))
            mstore(0x2d80, mulmod(mload(0x2d60), mload(0xb80), f_q))
            mstore(0x2da0, mulmod(1, mload(0x6c0), f_q))
            mstore(0x2dc0, mulmod(mload(0x9a0), mload(0x2da0), f_q))
            mstore(0x2de0, addmod(mload(0xa60), mload(0x2dc0), f_q))
            mstore(0x2e00, addmod(mload(0x2de0), mload(0x720), f_q))
            mstore(
                0x2e20,
                mulmod(4131629893567559867359510883348571134090853742863529169391034518566172092834, mload(0x6c0), f_q)
            )
            mstore(0x2e40, mulmod(mload(0x9a0), mload(0x2e20), f_q))
            mstore(0x2e60, addmod(mload(0x9e0), mload(0x2e40), f_q))
            mstore(0x2e80, addmod(mload(0x2e60), mload(0x720), f_q))
            mstore(0x2ea0, mulmod(mload(0x2e80), mload(0x2e00), f_q))
            mstore(
                0x2ec0,
                mulmod(8910878055287538404433155982483128285667088683464058436815641868457422632747, mload(0x6c0), f_q)
            )
            mstore(0x2ee0, mulmod(mload(0x9a0), mload(0x2ec0), f_q))
            mstore(0x2f00, addmod(mload(0x2960), mload(0x2ee0), f_q))
            mstore(0x2f20, addmod(mload(0x2f00), mload(0x720), f_q))
            mstore(0x2f40, mulmod(mload(0x2f20), mload(0x2ea0), f_q))
            mstore(0x2f60, mulmod(mload(0x2f40), mload(0xb60), f_q))
            mstore(0x2f80, addmod(mload(0x2d80), sub(f_q, mload(0x2f60)), f_q))
            mstore(0x2fa0, mulmod(mload(0x2f80), mload(0x2c00), f_q))
            mstore(0x2fc0, addmod(mload(0x2b20), mload(0x2fa0), f_q))
            mstore(0x2fe0, mulmod(mload(0x840), mload(0x2fc0), f_q))
            mstore(0x3000, addmod(1, sub(f_q, mload(0xba0)), f_q))
            mstore(0x3020, mulmod(mload(0x3000), mload(0x2480), f_q))
            mstore(0x3040, addmod(mload(0x2fe0), mload(0x3020), f_q))
            mstore(0x3060, mulmod(mload(0x840), mload(0x3040), f_q))
            mstore(0x3080, mulmod(mload(0xba0), mload(0xba0), f_q))
            mstore(0x30a0, addmod(mload(0x3080), sub(f_q, mload(0xba0)), f_q))
            mstore(0x30c0, mulmod(mload(0x30a0), mload(0x23a0), f_q))
            mstore(0x30e0, addmod(mload(0x3060), mload(0x30c0), f_q))
            mstore(0x3100, mulmod(mload(0x840), mload(0x30e0), f_q))
            mstore(0x3120, addmod(mload(0xbe0), mload(0x6c0), f_q))
            mstore(0x3140, mulmod(mload(0x3120), mload(0xbc0), f_q))
            mstore(0x3160, addmod(mload(0xc20), mload(0x720), f_q))
            mstore(0x3180, mulmod(mload(0x3160), mload(0x3140), f_q))
            mstore(0x31a0, mulmod(mload(0x9e0), mload(0xac0), f_q))
            mstore(0x31c0, addmod(mload(0x31a0), mload(0x6c0), f_q))
            mstore(0x31e0, mulmod(mload(0x31c0), mload(0xba0), f_q))
            mstore(0x3200, addmod(mload(0xa80), mload(0x720), f_q))
            mstore(0x3220, mulmod(mload(0x3200), mload(0x31e0), f_q))
            mstore(0x3240, addmod(mload(0x3180), sub(f_q, mload(0x3220)), f_q))
            mstore(0x3260, mulmod(mload(0x3240), mload(0x2c00), f_q))
            mstore(0x3280, addmod(mload(0x3100), mload(0x3260), f_q))
            mstore(0x32a0, mulmod(mload(0x840), mload(0x3280), f_q))
            mstore(0x32c0, addmod(mload(0xbe0), sub(f_q, mload(0xc20)), f_q))
            mstore(0x32e0, mulmod(mload(0x32c0), mload(0x2480), f_q))
            mstore(0x3300, addmod(mload(0x32a0), mload(0x32e0), f_q))
            mstore(0x3320, mulmod(mload(0x840), mload(0x3300), f_q))
            mstore(0x3340, mulmod(mload(0x32c0), mload(0x2c00), f_q))
            mstore(0x3360, addmod(mload(0xbe0), sub(f_q, mload(0xc00)), f_q))
            mstore(0x3380, mulmod(mload(0x3360), mload(0x3340), f_q))
            mstore(0x33a0, addmod(mload(0x3320), mload(0x3380), f_q))
            mstore(0x33c0, mulmod(mload(0x1120), mload(0x1120), f_q))
            mstore(0x33e0, mulmod(mload(0x33c0), mload(0x1120), f_q))
            mstore(0x3400, mulmod(mload(0x33e0), mload(0x1120), f_q))
            mstore(0x3420, mulmod(1, mload(0x1120), f_q))
            mstore(0x3440, mulmod(1, mload(0x33c0), f_q))
            mstore(0x3460, mulmod(1, mload(0x33e0), f_q))
            mstore(0x3480, mulmod(mload(0x33a0), mload(0x1140), f_q))
            mstore(0x34a0, mulmod(mload(0xe60), mload(0x9a0), f_q))
            mstore(0x34c0, mulmod(mload(0x34a0), mload(0x9a0), f_q))
            mstore(
                0x34e0,
                mulmod(mload(0x9a0), 9741553891420464328295280489650144566903017206473301385034033384879943874347, f_q)
            )
            mstore(0x3500, addmod(mload(0xd60), sub(f_q, mload(0x34e0)), f_q))
            mstore(0x3520, mulmod(mload(0x9a0), 1, f_q))
            mstore(0x3540, addmod(mload(0xd60), sub(f_q, mload(0x3520)), f_q))
            mstore(
                0x3560,
                mulmod(mload(0x9a0), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            mstore(0x3580, addmod(mload(0xd60), sub(f_q, mload(0x3560)), f_q))
            mstore(
                0x35a0,
                mulmod(mload(0x9a0), 11211301017135681023579411905410872569206244553457844956874280139879520583390, f_q)
            )
            mstore(0x35c0, addmod(mload(0xd60), sub(f_q, mload(0x35a0)), f_q))
            mstore(
                0x35e0,
                mulmod(mload(0x9a0), 3615478808282855240548287271348143516886772452944084747768312988864436725401, f_q)
            )
            mstore(0x3600, addmod(mload(0xd60), sub(f_q, mload(0x35e0)), f_q))
            mstore(
                0x3620,
                mulmod(
                    13213688729882003894512633350385593288217014177373218494356903340348818451480, mload(0x34a0), f_q
                )
            )
            mstore(0x3640, mulmod(mload(0x3620), 1, f_q))
            {
                let result := mulmod(mload(0xd60), mload(0x3620), f_q)
                result := addmod(mulmod(mload(0x9a0), sub(f_q, mload(0x3640)), f_q), result, f_q)
                mstore(13920, result)
            }
            mstore(
                0x3680,
                mulmod(8207090019724696496350398458716998472718344609680392612601596849934418295470, mload(0x34a0), f_q)
            )
            mstore(
                0x36a0,
                mulmod(mload(0x3680), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            {
                let result := mulmod(mload(0xd60), mload(0x3680), f_q)
                result := addmod(mulmod(mload(0x9a0), sub(f_q, mload(0x36a0)), f_q), result, f_q)
                mstore(14016, result)
            }
            mstore(
                0x36e0,
                mulmod(7391709068497399131897422873231908718558236401035363928063603272120120747483, mload(0x34a0), f_q)
            )
            mstore(
                0x3700,
                mulmod(
                    mload(0x36e0), 11211301017135681023579411905410872569206244553457844956874280139879520583390, f_q
                )
            )
            {
                let result := mulmod(mload(0xd60), mload(0x36e0), f_q)
                result := addmod(mulmod(mload(0x9a0), sub(f_q, mload(0x3700)), f_q), result, f_q)
                mstore(14112, result)
            }
            mstore(
                0x3740,
                mulmod(
                    19036273796805830823244991598792794567595348772040298280440552631112242221017, mload(0x34a0), f_q
                )
            )
            mstore(
                0x3760,
                mulmod(mload(0x3740), 3615478808282855240548287271348143516886772452944084747768312988864436725401, f_q)
            )
            {
                let result := mulmod(mload(0xd60), mload(0x3740), f_q)
                result := addmod(mulmod(mload(0x9a0), sub(f_q, mload(0x3760)), f_q), result, f_q)
                mstore(14208, result)
            }
            mstore(0x37a0, mulmod(1, mload(0x3540), f_q))
            mstore(0x37c0, mulmod(mload(0x37a0), mload(0x3580), f_q))
            mstore(0x37e0, mulmod(mload(0x37c0), mload(0x35c0), f_q))
            mstore(0x3800, mulmod(mload(0x37e0), mload(0x3600), f_q))
            mstore(
                0x3820,
                mulmod(13513867906530865119835332133273263211836799082674232843258448413103731898271, mload(0x9a0), f_q)
            )
            mstore(0x3840, mulmod(mload(0x3820), 1, f_q))
            {
                let result := mulmod(mload(0xd60), mload(0x3820), f_q)
                result := addmod(mulmod(mload(0x9a0), sub(f_q, mload(0x3840)), f_q), result, f_q)
                mstore(14432, result)
            }
            mstore(
                0x3880,
                mulmod(8374374965308410102411073611984011876711565317741801500439755773472076597346, mload(0x9a0), f_q)
            )
            mstore(
                0x38a0,
                mulmod(mload(0x3880), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            {
                let result := mulmod(mload(0xd60), mload(0x3880), f_q)
                result := addmod(mulmod(mload(0x9a0), sub(f_q, mload(0x38a0)), f_q), result, f_q)
                mstore(14528, result)
            }
            mstore(
                0x38e0,
                mulmod(12146688980418810893951125255607130521645347193942732958664170801695864621271, mload(0x9a0), f_q)
            )
            mstore(0x3900, mulmod(mload(0x38e0), 1, f_q))
            {
                let result := mulmod(mload(0xd60), mload(0x38e0), f_q)
                result := addmod(mulmod(mload(0x9a0), sub(f_q, mload(0x3900)), f_q), result, f_q)
                mstore(14624, result)
            }
            mstore(
                0x3940,
                mulmod(9741553891420464328295280489650144566903017206473301385034033384879943874346, mload(0x9a0), f_q)
            )
            mstore(
                0x3960,
                mulmod(mload(0x3940), 9741553891420464328295280489650144566903017206473301385034033384879943874347, f_q)
            )
            {
                let result := mulmod(mload(0xd60), mload(0x3940), f_q)
                result := addmod(mulmod(mload(0x9a0), sub(f_q, mload(0x3960)), f_q), result, f_q)
                mstore(14720, result)
            }
            mstore(0x39a0, mulmod(mload(0x37a0), mload(0x3500), f_q))
            {
                let result := mulmod(mload(0xd60), 1, f_q)
                result :=
                    addmod(
                        mulmod(
                            mload(0x9a0), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q
                        ),
                        result,
                        f_q
                    )
                mstore(14784, result)
            }
            {
                let prod := mload(0x3660)

                prod := mulmod(mload(0x36c0), prod, f_q)
                mstore(0x39e0, prod)

                prod := mulmod(mload(0x3720), prod, f_q)
                mstore(0x3a00, prod)

                prod := mulmod(mload(0x3780), prod, f_q)
                mstore(0x3a20, prod)

                prod := mulmod(mload(0x3860), prod, f_q)
                mstore(0x3a40, prod)

                prod := mulmod(mload(0x38c0), prod, f_q)
                mstore(0x3a60, prod)

                prod := mulmod(mload(0x37c0), prod, f_q)
                mstore(0x3a80, prod)

                prod := mulmod(mload(0x3920), prod, f_q)
                mstore(0x3aa0, prod)

                prod := mulmod(mload(0x3980), prod, f_q)
                mstore(0x3ac0, prod)

                prod := mulmod(mload(0x39a0), prod, f_q)
                mstore(0x3ae0, prod)

                prod := mulmod(mload(0x39c0), prod, f_q)
                mstore(0x3b00, prod)

                prod := mulmod(mload(0x37a0), prod, f_q)
                mstore(0x3b20, prod)
            }
            mstore(0x3b60, 32)
            mstore(0x3b80, 32)
            mstore(0x3ba0, 32)
            mstore(0x3bc0, mload(0x3b20))
            mstore(0x3be0, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
            mstore(0x3c00, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
            success := and(eq(staticcall(gas(), 0x5, 0x3b60, 0xc0, 0x3b40, 0x20), 1), success)
            {
                let inv := mload(0x3b40)
                let v

                v := mload(0x37a0)
                mstore(14240, mulmod(mload(0x3b00), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x39c0)
                mstore(14784, mulmod(mload(0x3ae0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x39a0)
                mstore(14752, mulmod(mload(0x3ac0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3980)
                mstore(14720, mulmod(mload(0x3aa0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3920)
                mstore(14624, mulmod(mload(0x3a80), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x37c0)
                mstore(14272, mulmod(mload(0x3a60), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x38c0)
                mstore(14528, mulmod(mload(0x3a40), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3860)
                mstore(14432, mulmod(mload(0x3a20), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3780)
                mstore(14208, mulmod(mload(0x3a00), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3720)
                mstore(14112, mulmod(mload(0x39e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x36c0)
                mstore(14016, mulmod(mload(0x3660), inv, f_q))
                inv := mulmod(v, inv, f_q)
                mstore(0x3660, inv)
            }
            {
                let result := mload(0x3660)
                result := addmod(mload(0x36c0), result, f_q)
                result := addmod(mload(0x3720), result, f_q)
                result := addmod(mload(0x3780), result, f_q)
                mstore(15392, result)
            }
            mstore(0x3c40, mulmod(mload(0x3800), mload(0x37c0), f_q))
            {
                let result := mload(0x3860)
                result := addmod(mload(0x38c0), result, f_q)
                mstore(15456, result)
            }
            mstore(0x3c80, mulmod(mload(0x3800), mload(0x39a0), f_q))
            {
                let result := mload(0x3920)
                result := addmod(mload(0x3980), result, f_q)
                mstore(15520, result)
            }
            mstore(0x3cc0, mulmod(mload(0x3800), mload(0x37a0), f_q))
            {
                let result := mload(0x39c0)
                mstore(15584, result)
            }
            {
                let prod := mload(0x3c20)

                prod := mulmod(mload(0x3c60), prod, f_q)
                mstore(0x3d00, prod)

                prod := mulmod(mload(0x3ca0), prod, f_q)
                mstore(0x3d20, prod)

                prod := mulmod(mload(0x3ce0), prod, f_q)
                mstore(0x3d40, prod)
            }
            mstore(0x3d80, 32)
            mstore(0x3da0, 32)
            mstore(0x3dc0, 32)
            mstore(0x3de0, mload(0x3d40))
            mstore(0x3e00, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
            mstore(0x3e20, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
            success := and(eq(staticcall(gas(), 0x5, 0x3d80, 0xc0, 0x3d60, 0x20), 1), success)
            {
                let inv := mload(0x3d60)
                let v

                v := mload(0x3ce0)
                mstore(15584, mulmod(mload(0x3d20), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3ca0)
                mstore(15520, mulmod(mload(0x3d00), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3c60)
                mstore(15456, mulmod(mload(0x3c20), inv, f_q))
                inv := mulmod(v, inv, f_q)
                mstore(0x3c20, inv)
            }
            mstore(0x3e40, mulmod(mload(0x3c40), mload(0x3c60), f_q))
            mstore(0x3e60, mulmod(mload(0x3c80), mload(0x3ca0), f_q))
            mstore(0x3e80, mulmod(mload(0x3cc0), mload(0x3ce0), f_q))
            mstore(0x3ea0, mulmod(mload(0xc60), mload(0xc60), f_q))
            mstore(0x3ec0, mulmod(mload(0x3ea0), mload(0xc60), f_q))
            mstore(0x3ee0, mulmod(mload(0x3ec0), mload(0xc60), f_q))
            mstore(0x3f00, mulmod(mload(0x3ee0), mload(0xc60), f_q))
            mstore(0x3f20, mulmod(mload(0x3f00), mload(0xc60), f_q))
            mstore(0x3f40, mulmod(mload(0x3f20), mload(0xc60), f_q))
            mstore(0x3f60, mulmod(mload(0x3f40), mload(0xc60), f_q))
            mstore(0x3f80, mulmod(mload(0x3f60), mload(0xc60), f_q))
            mstore(0x3fa0, mulmod(mload(0x3f80), mload(0xc60), f_q))
            mstore(0x3fc0, mulmod(mload(0xcc0), mload(0xcc0), f_q))
            mstore(0x3fe0, mulmod(mload(0x3fc0), mload(0xcc0), f_q))
            mstore(0x4000, mulmod(mload(0x3fe0), mload(0xcc0), f_q))
            {
                let result := mulmod(mload(0x9e0), mload(0x3660), f_q)
                result := addmod(mulmod(mload(0xa00), mload(0x36c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0xa20), mload(0x3720), f_q), result, f_q)
                result := addmod(mulmod(mload(0xa40), mload(0x3780), f_q), result, f_q)
                mstore(16416, result)
            }
            mstore(0x4040, mulmod(mload(0x4020), mload(0x3c20), f_q))
            mstore(0x4060, mulmod(sub(f_q, mload(0x4040)), 1, f_q))
            mstore(0x4080, mulmod(mload(0x4060), 1, f_q))
            mstore(0x40a0, mulmod(1, mload(0x3c40), f_q))
            {
                let result := mulmod(mload(0xb60), mload(0x3860), f_q)
                result := addmod(mulmod(mload(0xb80), mload(0x38c0), f_q), result, f_q)
                mstore(16576, result)
            }
            mstore(0x40e0, mulmod(mload(0x40c0), mload(0x3e40), f_q))
            mstore(0x4100, mulmod(sub(f_q, mload(0x40e0)), 1, f_q))
            mstore(0x4120, mulmod(mload(0x40a0), 1, f_q))
            {
                let result := mulmod(mload(0xba0), mload(0x3860), f_q)
                result := addmod(mulmod(mload(0xbc0), mload(0x38c0), f_q), result, f_q)
                mstore(16704, result)
            }
            mstore(0x4160, mulmod(mload(0x4140), mload(0x3e40), f_q))
            mstore(0x4180, mulmod(sub(f_q, mload(0x4160)), mload(0xc60), f_q))
            mstore(0x41a0, mulmod(mload(0x40a0), mload(0xc60), f_q))
            mstore(0x41c0, addmod(mload(0x4100), mload(0x4180), f_q))
            mstore(0x41e0, mulmod(mload(0x41c0), mload(0xcc0), f_q))
            mstore(0x4200, mulmod(mload(0x4120), mload(0xcc0), f_q))
            mstore(0x4220, mulmod(mload(0x41a0), mload(0xcc0), f_q))
            mstore(0x4240, addmod(mload(0x4080), mload(0x41e0), f_q))
            mstore(0x4260, mulmod(1, mload(0x3c80), f_q))
            {
                let result := mulmod(mload(0xbe0), mload(0x3920), f_q)
                result := addmod(mulmod(mload(0xc00), mload(0x3980), f_q), result, f_q)
                mstore(17024, result)
            }
            mstore(0x42a0, mulmod(mload(0x4280), mload(0x3e60), f_q))
            mstore(0x42c0, mulmod(sub(f_q, mload(0x42a0)), 1, f_q))
            mstore(0x42e0, mulmod(mload(0x4260), 1, f_q))
            mstore(0x4300, mulmod(mload(0x42c0), mload(0x3fc0), f_q))
            mstore(0x4320, mulmod(mload(0x42e0), mload(0x3fc0), f_q))
            mstore(0x4340, addmod(mload(0x4240), mload(0x4300), f_q))
            mstore(0x4360, mulmod(1, mload(0x3cc0), f_q))
            {
                let result := mulmod(mload(0xc20), mload(0x39c0), f_q)
                mstore(17280, result)
            }
            mstore(0x43a0, mulmod(mload(0x4380), mload(0x3e80), f_q))
            mstore(0x43c0, mulmod(sub(f_q, mload(0x43a0)), 1, f_q))
            mstore(0x43e0, mulmod(mload(0x4360), 1, f_q))
            {
                let result := mulmod(mload(0xa60), mload(0x39c0), f_q)
                mstore(17408, result)
            }
            mstore(0x4420, mulmod(mload(0x4400), mload(0x3e80), f_q))
            mstore(0x4440, mulmod(sub(f_q, mload(0x4420)), mload(0xc60), f_q))
            mstore(0x4460, mulmod(mload(0x4360), mload(0xc60), f_q))
            mstore(0x4480, addmod(mload(0x43c0), mload(0x4440), f_q))
            {
                let result := mulmod(mload(0xa80), mload(0x39c0), f_q)
                mstore(17568, result)
            }
            mstore(0x44c0, mulmod(mload(0x44a0), mload(0x3e80), f_q))
            mstore(0x44e0, mulmod(sub(f_q, mload(0x44c0)), mload(0x3ea0), f_q))
            mstore(0x4500, mulmod(mload(0x4360), mload(0x3ea0), f_q))
            mstore(0x4520, addmod(mload(0x4480), mload(0x44e0), f_q))
            {
                let result := mulmod(mload(0xaa0), mload(0x39c0), f_q)
                mstore(17728, result)
            }
            mstore(0x4560, mulmod(mload(0x4540), mload(0x3e80), f_q))
            mstore(0x4580, mulmod(sub(f_q, mload(0x4560)), mload(0x3ec0), f_q))
            mstore(0x45a0, mulmod(mload(0x4360), mload(0x3ec0), f_q))
            mstore(0x45c0, addmod(mload(0x4520), mload(0x4580), f_q))
            {
                let result := mulmod(mload(0xac0), mload(0x39c0), f_q)
                mstore(17888, result)
            }
            mstore(0x4600, mulmod(mload(0x45e0), mload(0x3e80), f_q))
            mstore(0x4620, mulmod(sub(f_q, mload(0x4600)), mload(0x3ee0), f_q))
            mstore(0x4640, mulmod(mload(0x4360), mload(0x3ee0), f_q))
            mstore(0x4660, addmod(mload(0x45c0), mload(0x4620), f_q))
            {
                let result := mulmod(mload(0xb00), mload(0x39c0), f_q)
                mstore(18048, result)
            }
            mstore(0x46a0, mulmod(mload(0x4680), mload(0x3e80), f_q))
            mstore(0x46c0, mulmod(sub(f_q, mload(0x46a0)), mload(0x3f00), f_q))
            mstore(0x46e0, mulmod(mload(0x4360), mload(0x3f00), f_q))
            mstore(0x4700, addmod(mload(0x4660), mload(0x46c0), f_q))
            {
                let result := mulmod(mload(0xb20), mload(0x39c0), f_q)
                mstore(18208, result)
            }
            mstore(0x4740, mulmod(mload(0x4720), mload(0x3e80), f_q))
            mstore(0x4760, mulmod(sub(f_q, mload(0x4740)), mload(0x3f20), f_q))
            mstore(0x4780, mulmod(mload(0x4360), mload(0x3f20), f_q))
            mstore(0x47a0, addmod(mload(0x4700), mload(0x4760), f_q))
            {
                let result := mulmod(mload(0xb40), mload(0x39c0), f_q)
                mstore(18368, result)
            }
            mstore(0x47e0, mulmod(mload(0x47c0), mload(0x3e80), f_q))
            mstore(0x4800, mulmod(sub(f_q, mload(0x47e0)), mload(0x3f40), f_q))
            mstore(0x4820, mulmod(mload(0x4360), mload(0x3f40), f_q))
            mstore(0x4840, addmod(mload(0x47a0), mload(0x4800), f_q))
            mstore(0x4860, mulmod(mload(0x3420), mload(0x3cc0), f_q))
            mstore(0x4880, mulmod(mload(0x3440), mload(0x3cc0), f_q))
            mstore(0x48a0, mulmod(mload(0x3460), mload(0x3cc0), f_q))
            {
                let result := mulmod(mload(0x3480), mload(0x39c0), f_q)
                mstore(18624, result)
            }
            mstore(0x48e0, mulmod(mload(0x48c0), mload(0x3e80), f_q))
            mstore(0x4900, mulmod(sub(f_q, mload(0x48e0)), mload(0x3f60), f_q))
            mstore(0x4920, mulmod(mload(0x4360), mload(0x3f60), f_q))
            mstore(0x4940, mulmod(mload(0x4860), mload(0x3f60), f_q))
            mstore(0x4960, mulmod(mload(0x4880), mload(0x3f60), f_q))
            mstore(0x4980, mulmod(mload(0x48a0), mload(0x3f60), f_q))
            mstore(0x49a0, addmod(mload(0x4840), mload(0x4900), f_q))
            {
                let result := mulmod(mload(0xae0), mload(0x39c0), f_q)
                mstore(18880, result)
            }
            mstore(0x49e0, mulmod(mload(0x49c0), mload(0x3e80), f_q))
            mstore(0x4a00, mulmod(sub(f_q, mload(0x49e0)), mload(0x3f80), f_q))
            mstore(0x4a20, mulmod(mload(0x4360), mload(0x3f80), f_q))
            mstore(0x4a40, addmod(mload(0x49a0), mload(0x4a00), f_q))
            mstore(0x4a60, mulmod(mload(0x4a40), mload(0x3fe0), f_q))
            mstore(0x4a80, mulmod(mload(0x43e0), mload(0x3fe0), f_q))
            mstore(0x4aa0, mulmod(mload(0x4460), mload(0x3fe0), f_q))
            mstore(0x4ac0, mulmod(mload(0x4500), mload(0x3fe0), f_q))
            mstore(0x4ae0, mulmod(mload(0x45a0), mload(0x3fe0), f_q))
            mstore(0x4b00, mulmod(mload(0x4640), mload(0x3fe0), f_q))
            mstore(0x4b20, mulmod(mload(0x46e0), mload(0x3fe0), f_q))
            mstore(0x4b40, mulmod(mload(0x4780), mload(0x3fe0), f_q))
            mstore(0x4b60, mulmod(mload(0x4820), mload(0x3fe0), f_q))
            mstore(0x4b80, mulmod(mload(0x4920), mload(0x3fe0), f_q))
            mstore(0x4ba0, mulmod(mload(0x4940), mload(0x3fe0), f_q))
            mstore(0x4bc0, mulmod(mload(0x4960), mload(0x3fe0), f_q))
            mstore(0x4be0, mulmod(mload(0x4980), mload(0x3fe0), f_q))
            mstore(0x4c00, mulmod(mload(0x4a20), mload(0x3fe0), f_q))
            mstore(0x4c20, addmod(mload(0x4340), mload(0x4a60), f_q))
            mstore(0x4c40, mulmod(1, mload(0x3800), f_q))
            mstore(0x4c60, mulmod(1, mload(0xd60), f_q))
            mstore(0x4c80, 0x0000000000000000000000000000000000000000000000000000000000000001)
            mstore(0x4ca0, 0x0000000000000000000000000000000000000000000000000000000000000002)
            mstore(0x4cc0, mload(0x4c20))
            success := and(eq(staticcall(gas(), 0x7, 0x4c80, 0x60, 0x4c80, 0x40), 1), success)
            mstore(0x4ce0, mload(0x4c80))
            mstore(0x4d00, mload(0x4ca0))
            mstore(0x4d20, mload(0x580))
            mstore(0x4d40, mload(0x5a0))
            success := and(eq(staticcall(gas(), 0x6, 0x4ce0, 0x80, 0x4ce0, 0x40), 1), success)
            mstore(0x4d60, mload(0x760))
            mstore(0x4d80, mload(0x780))
            mstore(0x4da0, mload(0x4200))
            success := and(eq(staticcall(gas(), 0x7, 0x4d60, 0x60, 0x4d60, 0x40), 1), success)
            mstore(0x4dc0, mload(0x4ce0))
            mstore(0x4de0, mload(0x4d00))
            mstore(0x4e00, mload(0x4d60))
            mstore(0x4e20, mload(0x4d80))
            success := and(eq(staticcall(gas(), 0x6, 0x4dc0, 0x80, 0x4dc0, 0x40), 1), success)
            mstore(0x4e40, mload(0x7a0))
            mstore(0x4e60, mload(0x7c0))
            mstore(0x4e80, mload(0x4220))
            success := and(eq(staticcall(gas(), 0x7, 0x4e40, 0x60, 0x4e40, 0x40), 1), success)
            mstore(0x4ea0, mload(0x4dc0))
            mstore(0x4ec0, mload(0x4de0))
            mstore(0x4ee0, mload(0x4e40))
            mstore(0x4f00, mload(0x4e60))
            success := and(eq(staticcall(gas(), 0x6, 0x4ea0, 0x80, 0x4ea0, 0x40), 1), success)
            mstore(0x4f20, mload(0x620))
            mstore(0x4f40, mload(0x640))
            mstore(0x4f60, mload(0x4320))
            success := and(eq(staticcall(gas(), 0x7, 0x4f20, 0x60, 0x4f20, 0x40), 1), success)
            mstore(0x4f80, mload(0x4ea0))
            mstore(0x4fa0, mload(0x4ec0))
            mstore(0x4fc0, mload(0x4f20))
            mstore(0x4fe0, mload(0x4f40))
            success := and(eq(staticcall(gas(), 0x6, 0x4f80, 0x80, 0x4f80, 0x40), 1), success)
            mstore(0x5000, mload(0x660))
            mstore(0x5020, mload(0x680))
            mstore(0x5040, mload(0x4a80))
            success := and(eq(staticcall(gas(), 0x7, 0x5000, 0x60, 0x5000, 0x40), 1), success)
            mstore(0x5060, mload(0x4f80))
            mstore(0x5080, mload(0x4fa0))
            mstore(0x50a0, mload(0x5000))
            mstore(0x50c0, mload(0x5020))
            success := and(eq(staticcall(gas(), 0x6, 0x5060, 0x80, 0x5060, 0x40), 1), success)
            mstore(0x50e0, 0x2725c45f79277a1e49079f8f261257c8550ea0a058bfd904722c6c7d0562488b)
            mstore(0x5100, 0x019b3c97cc47799a2e5e9ed3785ecd09af91f623fb5974da6e1eea4fae94a82c)
            mstore(0x5120, mload(0x4aa0))
            success := and(eq(staticcall(gas(), 0x7, 0x50e0, 0x60, 0x50e0, 0x40), 1), success)
            mstore(0x5140, mload(0x5060))
            mstore(0x5160, mload(0x5080))
            mstore(0x5180, mload(0x50e0))
            mstore(0x51a0, mload(0x5100))
            success := and(eq(staticcall(gas(), 0x6, 0x5140, 0x80, 0x5140, 0x40), 1), success)
            mstore(0x51c0, 0x2eb40e2b0c13a6f4b989cffa9dbc452447bfd9f04a79f6379aefea8c9850a550)
            mstore(0x51e0, 0x0efe5496541e2bd648d490f11ad542e1dec3127f818b8065843d0dd81358416c)
            mstore(0x5200, mload(0x4ac0))
            success := and(eq(staticcall(gas(), 0x7, 0x51c0, 0x60, 0x51c0, 0x40), 1), success)
            mstore(0x5220, mload(0x5140))
            mstore(0x5240, mload(0x5160))
            mstore(0x5260, mload(0x51c0))
            mstore(0x5280, mload(0x51e0))
            success := and(eq(staticcall(gas(), 0x6, 0x5220, 0x80, 0x5220, 0x40), 1), success)
            mstore(0x52a0, 0x1c36e29c35709d46855eefd1ac8130dd83f11fc9b388139220b3bfd5cdae5c5d)
            mstore(0x52c0, 0x1a9329880a4592dfee801d0ef2c55b960fdec29956db5c9dd73df44ecd2d5fac)
            mstore(0x52e0, mload(0x4ae0))
            success := and(eq(staticcall(gas(), 0x7, 0x52a0, 0x60, 0x52a0, 0x40), 1), success)
            mstore(0x5300, mload(0x5220))
            mstore(0x5320, mload(0x5240))
            mstore(0x5340, mload(0x52a0))
            mstore(0x5360, mload(0x52c0))
            success := and(eq(staticcall(gas(), 0x6, 0x5300, 0x80, 0x5300, 0x40), 1), success)
            mstore(0x5380, 0x2731b42d99282a176bc85b55eea0fa4ba78d1ef062dcf2af8a69db4c79ee3387)
            mstore(0x53a0, 0x2d5f6780086ce3b88c40ea3a65a54dab978e6a850d3e610a92616a77896497c2)
            mstore(0x53c0, mload(0x4b00))
            success := and(eq(staticcall(gas(), 0x7, 0x5380, 0x60, 0x5380, 0x40), 1), success)
            mstore(0x53e0, mload(0x5300))
            mstore(0x5400, mload(0x5320))
            mstore(0x5420, mload(0x5380))
            mstore(0x5440, mload(0x53a0))
            success := and(eq(staticcall(gas(), 0x6, 0x53e0, 0x80, 0x53e0, 0x40), 1), success)
            mstore(0x5460, 0x0f92f8da112644e5ade9bbd32dd4d2b906fd5cc359fdc6fe96fd5da112bf3f23)
            mstore(0x5480, 0x2c12aa300b69ebcccc3c2621c11cbb396cb0793a6fc9712f6eba83edd9b8f5cc)
            mstore(0x54a0, mload(0x4b20))
            success := and(eq(staticcall(gas(), 0x7, 0x5460, 0x60, 0x5460, 0x40), 1), success)
            mstore(0x54c0, mload(0x53e0))
            mstore(0x54e0, mload(0x5400))
            mstore(0x5500, mload(0x5460))
            mstore(0x5520, mload(0x5480))
            success := and(eq(staticcall(gas(), 0x6, 0x54c0, 0x80, 0x54c0, 0x40), 1), success)
            mstore(0x5540, 0x0c9646f84831abc4015665ebd85b01ed888088e1df57a8c0757172539b43bb1f)
            mstore(0x5560, 0x1796888550cdbb88c9deecd1b90fb39e94e1721d4fed58c7bfa57f4a1cc20b63)
            mstore(0x5580, mload(0x4b40))
            success := and(eq(staticcall(gas(), 0x7, 0x5540, 0x60, 0x5540, 0x40), 1), success)
            mstore(0x55a0, mload(0x54c0))
            mstore(0x55c0, mload(0x54e0))
            mstore(0x55e0, mload(0x5540))
            mstore(0x5600, mload(0x5560))
            success := and(eq(staticcall(gas(), 0x6, 0x55a0, 0x80, 0x55a0, 0x40), 1), success)
            mstore(0x5620, 0x0ce62747c6eb015c2eec08b14daecd26c132056591860c4cf196bb608d511656)
            mstore(0x5640, 0x23188b4e1dc65f42cc007f8def039fb65b19146309c4179e490ca47fb2764827)
            mstore(0x5660, mload(0x4b60))
            success := and(eq(staticcall(gas(), 0x7, 0x5620, 0x60, 0x5620, 0x40), 1), success)
            mstore(0x5680, mload(0x55a0))
            mstore(0x56a0, mload(0x55c0))
            mstore(0x56c0, mload(0x5620))
            mstore(0x56e0, mload(0x5640))
            success := and(eq(staticcall(gas(), 0x6, 0x5680, 0x80, 0x5680, 0x40), 1), success)
            mstore(0x5700, mload(0x880))
            mstore(0x5720, mload(0x8a0))
            mstore(0x5740, mload(0x4b80))
            success := and(eq(staticcall(gas(), 0x7, 0x5700, 0x60, 0x5700, 0x40), 1), success)
            mstore(0x5760, mload(0x5680))
            mstore(0x5780, mload(0x56a0))
            mstore(0x57a0, mload(0x5700))
            mstore(0x57c0, mload(0x5720))
            success := and(eq(staticcall(gas(), 0x6, 0x5760, 0x80, 0x5760, 0x40), 1), success)
            mstore(0x57e0, mload(0x8c0))
            mstore(0x5800, mload(0x8e0))
            mstore(0x5820, mload(0x4ba0))
            success := and(eq(staticcall(gas(), 0x7, 0x57e0, 0x60, 0x57e0, 0x40), 1), success)
            mstore(0x5840, mload(0x5760))
            mstore(0x5860, mload(0x5780))
            mstore(0x5880, mload(0x57e0))
            mstore(0x58a0, mload(0x5800))
            success := and(eq(staticcall(gas(), 0x6, 0x5840, 0x80, 0x5840, 0x40), 1), success)
            mstore(0x58c0, mload(0x900))
            mstore(0x58e0, mload(0x920))
            mstore(0x5900, mload(0x4bc0))
            success := and(eq(staticcall(gas(), 0x7, 0x58c0, 0x60, 0x58c0, 0x40), 1), success)
            mstore(0x5920, mload(0x5840))
            mstore(0x5940, mload(0x5860))
            mstore(0x5960, mload(0x58c0))
            mstore(0x5980, mload(0x58e0))
            success := and(eq(staticcall(gas(), 0x6, 0x5920, 0x80, 0x5920, 0x40), 1), success)
            mstore(0x59a0, mload(0x940))
            mstore(0x59c0, mload(0x960))
            mstore(0x59e0, mload(0x4be0))
            success := and(eq(staticcall(gas(), 0x7, 0x59a0, 0x60, 0x59a0, 0x40), 1), success)
            mstore(0x5a00, mload(0x5920))
            mstore(0x5a20, mload(0x5940))
            mstore(0x5a40, mload(0x59a0))
            mstore(0x5a60, mload(0x59c0))
            success := and(eq(staticcall(gas(), 0x6, 0x5a00, 0x80, 0x5a00, 0x40), 1), success)
            mstore(0x5a80, mload(0x7e0))
            mstore(0x5aa0, mload(0x800))
            mstore(0x5ac0, mload(0x4c00))
            success := and(eq(staticcall(gas(), 0x7, 0x5a80, 0x60, 0x5a80, 0x40), 1), success)
            mstore(0x5ae0, mload(0x5a00))
            mstore(0x5b00, mload(0x5a20))
            mstore(0x5b20, mload(0x5a80))
            mstore(0x5b40, mload(0x5aa0))
            success := and(eq(staticcall(gas(), 0x6, 0x5ae0, 0x80, 0x5ae0, 0x40), 1), success)
            mstore(0x5b60, mload(0xd00))
            mstore(0x5b80, mload(0xd20))
            mstore(0x5ba0, sub(f_q, mload(0x4c40)))
            success := and(eq(staticcall(gas(), 0x7, 0x5b60, 0x60, 0x5b60, 0x40), 1), success)
            mstore(0x5bc0, mload(0x5ae0))
            mstore(0x5be0, mload(0x5b00))
            mstore(0x5c00, mload(0x5b60))
            mstore(0x5c20, mload(0x5b80))
            success := and(eq(staticcall(gas(), 0x6, 0x5bc0, 0x80, 0x5bc0, 0x40), 1), success)
            mstore(0x5c40, mload(0xda0))
            mstore(0x5c60, mload(0xdc0))
            mstore(0x5c80, mload(0x4c60))
            success := and(eq(staticcall(gas(), 0x7, 0x5c40, 0x60, 0x5c40, 0x40), 1), success)
            mstore(0x5ca0, mload(0x5bc0))
            mstore(0x5cc0, mload(0x5be0))
            mstore(0x5ce0, mload(0x5c40))
            mstore(0x5d00, mload(0x5c60))
            success := and(eq(staticcall(gas(), 0x6, 0x5ca0, 0x80, 0x5ca0, 0x40), 1), success)
            mstore(0x5d20, mload(0x5ca0))
            mstore(0x5d40, mload(0x5cc0))
            mstore(0x5d60, mload(0xda0))
            mstore(0x5d80, mload(0xdc0))
            mstore(0x5da0, mload(0xde0))
            mstore(0x5dc0, mload(0xe00))
            mstore(0x5de0, mload(0xe20))
            mstore(0x5e00, mload(0xe40))
            mstore(0x5e20, keccak256(0x5d20, 256))
            mstore(24128, mod(mload(24096), f_q))
            mstore(0x5e60, mulmod(mload(0x5e40), mload(0x5e40), f_q))
            mstore(0x5e80, mulmod(1, mload(0x5e40), f_q))
            mstore(0x5ea0, mload(0x5da0))
            mstore(0x5ec0, mload(0x5dc0))
            mstore(0x5ee0, mload(0x5e80))
            success := and(eq(staticcall(gas(), 0x7, 0x5ea0, 0x60, 0x5ea0, 0x40), 1), success)
            mstore(0x5f00, mload(0x5d20))
            mstore(0x5f20, mload(0x5d40))
            mstore(0x5f40, mload(0x5ea0))
            mstore(0x5f60, mload(0x5ec0))
            success := and(eq(staticcall(gas(), 0x6, 0x5f00, 0x80, 0x5f00, 0x40), 1), success)
            mstore(0x5f80, mload(0x5de0))
            mstore(0x5fa0, mload(0x5e00))
            mstore(0x5fc0, mload(0x5e80))
            success := and(eq(staticcall(gas(), 0x7, 0x5f80, 0x60, 0x5f80, 0x40), 1), success)
            mstore(0x5fe0, mload(0x5d60))
            mstore(0x6000, mload(0x5d80))
            mstore(0x6020, mload(0x5f80))
            mstore(0x6040, mload(0x5fa0))
            success := and(eq(staticcall(gas(), 0x6, 0x5fe0, 0x80, 0x5fe0, 0x40), 1), success)
            mstore(0x6060, mload(0x5f00))
            mstore(0x6080, mload(0x5f20))
            mstore(0x60a0, 0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2)
            mstore(0x60c0, 0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed)
            mstore(0x60e0, 0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b)
            mstore(0x6100, 0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa)
            mstore(0x6120, mload(0x5fe0))
            mstore(0x6140, mload(0x6000))
            mstore(0x6160, 0x172aa93c41f16e1e04d62ac976a5d945f4be0acab990c6dc19ac4a7cf68bf77b)
            mstore(0x6180, 0x2ae0c8c3a090f7200ff398ee9845bbae8f8c1445ae7b632212775f60a0e21600)
            mstore(0x61a0, 0x190fa476a5b352809ed41d7a0d7fe12b8f685e3c12a6d83855dba27aaf469643)
            mstore(0x61c0, 0x1c0a500618907df9e4273d5181e31088deb1f05132de037cbfe73888f97f77c9)
            success := and(eq(staticcall(gas(), 0x8, 0x6060, 0x180, 0x6060, 0x20), 1), success)
            success := and(eq(mload(0x6060), 1), success)

            // Revert if anything fails
            if iszero(success) { revert(0, 0) }

            // Return empty bytes on success
            return(0, 0)
        }
    }
}
