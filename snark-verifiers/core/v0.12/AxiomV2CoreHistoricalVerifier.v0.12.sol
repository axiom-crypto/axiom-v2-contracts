// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract AxiomV2CoreHistoricalVerifier {
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
            mstore(0x580, mod(calldataload(0x4e0), f_q))
            mstore(0x5a0, mod(calldataload(0x500), f_q))
            mstore(0x5c0, mod(calldataload(0x520), f_q))
            mstore(0x5e0, mod(calldataload(0x540), f_q))
            mstore(0x600, mod(calldataload(0x560), f_q))
            mstore(0x620, mod(calldataload(0x580), f_q))
            mstore(0x640, mod(calldataload(0x5a0), f_q))
            mstore(0x660, mod(calldataload(0x5c0), f_q))
            mstore(0x680, mod(calldataload(0x5e0), f_q))
            mstore(0x6a0, mod(calldataload(0x600), f_q))
            mstore(0x6c0, mod(calldataload(0x620), f_q))
            mstore(0x6e0, mod(calldataload(0x640), f_q))
            mstore(0x700, mod(calldataload(0x660), f_q))
            mstore(0x720, mod(calldataload(0x680), f_q))
            mstore(0x80, 7075583489971260291803384602225991605467495782703761057579037289212700492339)

            {
                let x := calldataload(0x6a0)
                mstore(0x740, x)
                let y := calldataload(0x6c0)
                mstore(0x760, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x780, keccak256(0x80, 1792))
            {
                let hash := mload(0x780)
                mstore(0x7a0, mod(hash, f_q))
                mstore(0x7c0, hash)
            }

            {
                let x := calldataload(0x6e0)
                mstore(0x7e0, x)
                let y := calldataload(0x700)
                mstore(0x800, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x720)
                mstore(0x820, x)
                let y := calldataload(0x740)
                mstore(0x840, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x860, keccak256(0x7c0, 160))
            {
                let hash := mload(0x860)
                mstore(0x880, mod(hash, f_q))
                mstore(0x8a0, hash)
            }
            mstore8(2240, 1)
            mstore(0x8c0, keccak256(0x8a0, 33))
            {
                let hash := mload(0x8c0)
                mstore(0x8e0, mod(hash, f_q))
                mstore(0x900, hash)
            }

            {
                let x := calldataload(0x760)
                mstore(0x920, x)
                let y := calldataload(0x780)
                mstore(0x940, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x7a0)
                mstore(0x960, x)
                let y := calldataload(0x7c0)
                mstore(0x980, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x7e0)
                mstore(0x9a0, x)
                let y := calldataload(0x800)
                mstore(0x9c0, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x9e0, keccak256(0x900, 224))
            {
                let hash := mload(0x9e0)
                mstore(0xa00, mod(hash, f_q))
                mstore(0xa20, hash)
            }

            {
                let x := calldataload(0x820)
                mstore(0xa40, x)
                let y := calldataload(0x840)
                mstore(0xa60, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x860)
                mstore(0xa80, x)
                let y := calldataload(0x880)
                mstore(0xaa0, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x8a0)
                mstore(0xac0, x)
                let y := calldataload(0x8c0)
                mstore(0xae0, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x8e0)
                mstore(0xb00, x)
                let y := calldataload(0x900)
                mstore(0xb20, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0xb40, keccak256(0xa20, 288))
            {
                let hash := mload(0xb40)
                mstore(0xb60, mod(hash, f_q))
                mstore(0xb80, hash)
            }
            mstore(0xba0, mod(calldataload(0x920), f_q))
            mstore(0xbc0, mod(calldataload(0x940), f_q))
            mstore(0xbe0, mod(calldataload(0x960), f_q))
            mstore(0xc00, mod(calldataload(0x980), f_q))
            mstore(0xc20, mod(calldataload(0x9a0), f_q))
            mstore(0xc40, mod(calldataload(0x9c0), f_q))
            mstore(0xc60, mod(calldataload(0x9e0), f_q))
            mstore(0xc80, mod(calldataload(0xa00), f_q))
            mstore(0xca0, mod(calldataload(0xa20), f_q))
            mstore(0xcc0, mod(calldataload(0xa40), f_q))
            mstore(0xce0, mod(calldataload(0xa60), f_q))
            mstore(0xd00, mod(calldataload(0xa80), f_q))
            mstore(0xd20, mod(calldataload(0xaa0), f_q))
            mstore(0xd40, mod(calldataload(0xac0), f_q))
            mstore(0xd60, mod(calldataload(0xae0), f_q))
            mstore(0xd80, mod(calldataload(0xb00), f_q))
            mstore(0xda0, mod(calldataload(0xb20), f_q))
            mstore(0xdc0, mod(calldataload(0xb40), f_q))
            mstore(0xde0, mod(calldataload(0xb60), f_q))
            mstore(0xe00, keccak256(0xb80, 640))
            {
                let hash := mload(0xe00)
                mstore(0xe20, mod(hash, f_q))
                mstore(0xe40, hash)
            }
            mstore8(3680, 1)
            mstore(0xe60, keccak256(0xe40, 33))
            {
                let hash := mload(0xe60)
                mstore(0xe80, mod(hash, f_q))
                mstore(0xea0, hash)
            }

            {
                let x := calldataload(0xb80)
                mstore(0xec0, x)
                let y := calldataload(0xba0)
                mstore(0xee0, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0xf00, keccak256(0xea0, 96))
            {
                let hash := mload(0xf00)
                mstore(0xf20, mod(hash, f_q))
                mstore(0xf40, hash)
            }

            {
                let x := calldataload(0xbc0)
                mstore(0xf60, x)
                let y := calldataload(0xbe0)
                mstore(0xf80, y)
                success := and(validate_ec_point(x, y), success)
            }
            {
                let x := mload(0xa0)
                x := add(x, shl(88, mload(0xc0)))
                x := add(x, shl(176, mload(0xe0)))
                mstore(4000, x)
                let y := mload(0x100)
                y := add(y, shl(88, mload(0x120)))
                y := add(y, shl(176, mload(0x140)))
                mstore(4032, y)

                success := and(validate_ec_point(x, y), success)
            }
            {
                let x := mload(0x160)
                x := add(x, shl(88, mload(0x180)))
                x := add(x, shl(176, mload(0x1a0)))
                mstore(4064, x)
                let y := mload(0x1c0)
                y := add(y, shl(88, mload(0x1e0)))
                y := add(y, shl(176, mload(0x200)))
                mstore(4096, y)

                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x1020, mulmod(mload(0xb60), mload(0xb60), f_q))
            mstore(0x1040, mulmod(mload(0x1020), mload(0x1020), f_q))
            mstore(0x1060, mulmod(mload(0x1040), mload(0x1040), f_q))
            mstore(0x1080, mulmod(mload(0x1060), mload(0x1060), f_q))
            mstore(0x10a0, mulmod(mload(0x1080), mload(0x1080), f_q))
            mstore(0x10c0, mulmod(mload(0x10a0), mload(0x10a0), f_q))
            mstore(0x10e0, mulmod(mload(0x10c0), mload(0x10c0), f_q))
            mstore(0x1100, mulmod(mload(0x10e0), mload(0x10e0), f_q))
            mstore(0x1120, mulmod(mload(0x1100), mload(0x1100), f_q))
            mstore(0x1140, mulmod(mload(0x1120), mload(0x1120), f_q))
            mstore(0x1160, mulmod(mload(0x1140), mload(0x1140), f_q))
            mstore(0x1180, mulmod(mload(0x1160), mload(0x1160), f_q))
            mstore(0x11a0, mulmod(mload(0x1180), mload(0x1180), f_q))
            mstore(0x11c0, mulmod(mload(0x11a0), mload(0x11a0), f_q))
            mstore(0x11e0, mulmod(mload(0x11c0), mload(0x11c0), f_q))
            mstore(0x1200, mulmod(mload(0x11e0), mload(0x11e0), f_q))
            mstore(0x1220, mulmod(mload(0x1200), mload(0x1200), f_q))
            mstore(0x1240, mulmod(mload(0x1220), mload(0x1220), f_q))
            mstore(0x1260, mulmod(mload(0x1240), mload(0x1240), f_q))
            mstore(0x1280, mulmod(mload(0x1260), mload(0x1260), f_q))
            mstore(0x12a0, mulmod(mload(0x1280), mload(0x1280), f_q))
            mstore(0x12c0, mulmod(mload(0x12a0), mload(0x12a0), f_q))
            mstore(0x12e0, mulmod(mload(0x12c0), mload(0x12c0), f_q))
            mstore(
                0x1300,
                addmod(
                    mload(0x12e0), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q
                )
            )
            mstore(
                0x1320,
                mulmod(
                    mload(0x1300), 21888240262557392955334514970720457388010314637169927192662615958087340972065, f_q
                )
            )
            mstore(
                0x1340,
                mulmod(mload(0x1320), 4506835738822104338668100540817374747935106310012997856968187171738630203507, f_q)
            )
            mstore(
                0x1360,
                addmod(mload(0xb60), 17381407133017170883578305204439900340613258090403036486730017014837178292110, f_q)
            )
            mstore(
                0x1380,
                mulmod(
                    mload(0x1320), 21710372849001950800533397158415938114909991150039389063546734567764856596059, f_q
                )
            )
            mstore(
                0x13a0,
                addmod(mload(0xb60), 177870022837324421713008586841336973638373250376645280151469618810951899558, f_q)
            )
            mstore(
                0x13c0,
                mulmod(mload(0x1320), 1887003188133998471169152042388914354640772748308168868301418279904560637395, f_q)
            )
            mstore(
                0x13e0,
                addmod(mload(0xb60), 20001239683705276751077253702868360733907591652107865475396785906671247858222, f_q)
            )
            mstore(
                0x1400,
                mulmod(mload(0x1320), 2785514556381676080176937710880804108647911392478702105860685610379369825016, f_q)
            )
            mstore(
                0x1420,
                addmod(mload(0xb60), 19102728315457599142069468034376470979900453007937332237837518576196438670601, f_q)
            )
            mstore(
                0x1440,
                mulmod(
                    mload(0x1320), 14655294445420895451632927078981340937842238432098198055057679026789553137428, f_q
                )
            )
            mstore(
                0x1460,
                addmod(mload(0xb60), 7232948426418379770613478666275934150706125968317836288640525159786255358189, f_q)
            )
            mstore(
                0x1480,
                mulmod(mload(0x1320), 8734126352828345679573237859165904705806588461301144420590422589042130041188, f_q)
            )
            mstore(
                0x14a0,
                addmod(mload(0xb60), 13154116519010929542673167886091370382741775939114889923107781597533678454429, f_q)
            )
            mstore(
                0x14c0,
                mulmod(mload(0x1320), 9741553891420464328295280489650144566903017206473301385034033384879943874347, f_q)
            )
            mstore(
                0x14e0,
                addmod(mload(0xb60), 12146688980418810893951125255607130521645347193942732958664170801695864621270, f_q)
            )
            mstore(0x1500, mulmod(mload(0x1320), 1, f_q))
            mstore(
                0x1520,
                addmod(mload(0xb60), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q)
            )
            mstore(
                0x1540,
                mulmod(mload(0x1320), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            mstore(
                0x1560,
                addmod(mload(0xb60), 13513867906530865119835332133273263211836799082674232843258448413103731898270, f_q)
            )
            mstore(
                0x1580,
                mulmod(
                    mload(0x1320), 11211301017135681023579411905410872569206244553457844956874280139879520583390, f_q
                )
            )
            mstore(
                0x15a0,
                addmod(mload(0xb60), 10676941854703594198666993839846402519342119846958189386823924046696287912227, f_q)
            )
            mstore(
                0x15c0,
                mulmod(mload(0x1320), 3615478808282855240548287271348143516886772452944084747768312988864436725401, f_q)
            )
            mstore(
                0x15e0,
                addmod(mload(0xb60), 18272764063556419981698118473909131571661591947471949595929891197711371770216, f_q)
            )
            mstore(
                0x1600,
                mulmod(mload(0x1320), 1426404432721484388505361748317961535523355871255605456897797744433766488507, f_q)
            )
            mstore(
                0x1620,
                addmod(mload(0xb60), 20461838439117790833741043996939313553025008529160428886800406442142042007110, f_q)
            )
            mstore(
                0x1640,
                mulmod(mload(0x1320), 216092043779272773661818549620449970334216366264741118684015851799902419467, f_q)
            )
            mstore(
                0x1660,
                addmod(mload(0xb60), 21672150828060002448584587195636825118214148034151293225014188334775906076150, f_q)
            )
            mstore(
                0x1680,
                mulmod(
                    mload(0x1320), 12619617507853212586156872920672483948819476989779550311307282715684870266992, f_q
                )
            )
            mstore(
                0x16a0,
                addmod(mload(0xb60), 9268625363986062636089532824584791139728887410636484032390921470890938228625, f_q)
            )
            mstore(
                0x16c0,
                mulmod(
                    mload(0x1320), 18610195890048912503953886742825279624920778288956610528523679659246523534888, f_q
                )
            )
            mstore(
                0x16e0,
                addmod(mload(0xb60), 3278046981790362718292519002431995463627586111459423815174524527329284960729, f_q)
            )
            mstore(
                0x1700,
                mulmod(
                    mload(0x1320), 19032961837237948602743626455740240236231119053033140765040043513661803148152, f_q
                )
            )
            mstore(
                0x1720,
                addmod(mload(0xb60), 2855281034601326619502779289517034852317245347382893578658160672914005347465, f_q)
            )
            mstore(
                0x1740,
                mulmod(
                    mload(0x1320), 14875928112196239563830800280253496262679717528621719058794366823499719730250, f_q
                )
            )
            mstore(
                0x1760,
                addmod(mload(0xb60), 7012314759643035658415605465003778825868646871794315284903837363076088765367, f_q)
            )
            mstore(
                0x1780,
                mulmod(mload(0x1320), 915149353520972163646494413843788069594022902357002628455555785223409501882, f_q)
            )
            mstore(
                0x17a0,
                addmod(mload(0xb60), 20973093518318303058599911331413487018954341498059031715242648401352398993735, f_q)
            )
            mstore(
                0x17c0,
                mulmod(mload(0x1320), 5522161504810533295870699551020523636289972223872138525048055197429246400245, f_q)
            )
            mstore(
                0x17e0,
                addmod(mload(0xb60), 16366081367028741926375706194236751452258392176543895818650148989146562095372, f_q)
            )
            mstore(
                0x1800,
                mulmod(mload(0x1320), 3766081621734395783232337525162072736827576297943013392955872170138036189193, f_q)
            )
            mstore(
                0x1820,
                addmod(mload(0xb60), 18122161250104879439014068220095202351720788102473020950742332016437772306424, f_q)
            )
            mstore(
                0x1840,
                mulmod(mload(0x1320), 9100833993744738801214480881117348002768153232283708533639316963648253510584, f_q)
            )
            mstore(
                0x1860,
                addmod(mload(0xb60), 12787408878094536421031924864139927085780211168132325810058887222927554985033, f_q)
            )
            mstore(
                0x1880,
                mulmod(mload(0x1320), 4245441013247250116003069945606352967193023389718465410501109428393342802981, f_q)
            )
            mstore(
                0x18a0,
                addmod(mload(0xb60), 17642801858592025106243335799650922121355341010697568933197094758182465692636, f_q)
            )
            mstore(
                0x18c0,
                mulmod(mload(0x1320), 6132660129994545119218258312491950835441607143741804980633129304664017206141, f_q)
            )
            mstore(
                0x18e0,
                addmod(mload(0xb60), 15755582741844730103028147432765324253106757256674229363065074881911791289476, f_q)
            )
            mstore(
                0x1900,
                mulmod(mload(0x1320), 5854133144571823792863860130267644613802765696134002830362054821530146160770, f_q)
            )
            mstore(
                0x1920,
                addmod(mload(0xb60), 16034109727267451429382545614989630474745598704282031513336149365045662334847, f_q)
            )
            mstore(
                0x1940,
                mulmod(mload(0x1320), 515148244606945972463850631189471072103916690263705052318085725998468254533, f_q)
            )
            mstore(
                0x1960,
                addmod(mload(0xb60), 21373094627232329249782555114067804016444447710152329291380118460577340241084, f_q)
            )
            mstore(
                0x1980,
                mulmod(mload(0x1320), 5980488956150442207659150513163747165544364597008566989111579977672498964212, f_q)
            )
            mstore(
                0x19a0,
                addmod(mload(0xb60), 15907753915688833014587255232093527923003999803407467354586624208903309531405, f_q)
            )
            mstore(
                0x19c0,
                mulmod(mload(0x1320), 5223738580615264174925218065001555728265216895679471490312087802465486318994, f_q)
            )
            mstore(
                0x19e0,
                addmod(mload(0xb60), 16664504291224011047321187680255719360283147504736562853386116384110322176623, f_q)
            )
            mstore(
                0x1a00,
                mulmod(
                    mload(0x1320), 14557038802599140430182096396825290815503940951075961210638273254419942783582, f_q
                )
            )
            mstore(
                0x1a20,
                addmod(mload(0xb60), 7331204069240134792064309348431984273044423449340073133059930932155865712035, f_q)
            )
            mstore(
                0x1a40,
                mulmod(
                    mload(0x1320), 16976236069879939850923145256911338076234942200101755618884183331004076579046, f_q
                )
            )
            mstore(
                0x1a60,
                addmod(mload(0xb60), 4912006801959335371323260488345937012313422200314278724814020855571731916571, f_q)
            )
            mstore(
                0x1a80,
                mulmod(
                    mload(0x1320), 13553911191894110065493137367144919847521088405945523452288398666974237857208, f_q
                )
            )
            mstore(
                0x1aa0,
                addmod(mload(0xb60), 8334331679945165156753268378112355241027275994470510891409805519601570638409, f_q)
            )
            mstore(
                0x1ac0,
                mulmod(
                    mload(0x1320), 12222687719926148270818604386979005738180875192307070468454582955273533101023, f_q
                )
            )
            mstore(
                0x1ae0,
                addmod(mload(0xb60), 9665555151913126951427801358278269350367489208108963875243621231302275394594, f_q)
            )
            mstore(
                0x1b00,
                mulmod(mload(0x1320), 9697063347556872083384215826199993067635178715531258559890418744774301211662, f_q)
            )
            mstore(
                0x1b20,
                addmod(mload(0xb60), 12191179524282403138862189919057282020913185684884775783807785441801507283955, f_q)
            )
            mstore(
                0x1b40,
                mulmod(
                    mload(0x1320), 13783318220968413117070077848579881425001701814458176881760898225529300547844, f_q
                )
            )
            mstore(
                0x1b60,
                addmod(mload(0xb60), 8104924650870862105176327896677393663546662585957857461937305961046507947773, f_q)
            )
            mstore(
                0x1b80,
                mulmod(
                    mload(0x1320), 10807735674816066981985242612061336605021639643453679977988966079770672437131, f_q
                )
            )
            mstore(
                0x1ba0,
                addmod(mload(0xb60), 11080507197023208240261163133195938483526724756962354365709238106805136058486, f_q)
            )
            mstore(
                0x1bc0,
                mulmod(
                    mload(0x1320), 15487660954688013862248478071816391715224351867581977083810729441220383572585, f_q
                )
            )
            mstore(
                0x1be0,
                addmod(mload(0xb60), 6400581917151261359997927673440883373324012532834057259887474745355424923032, f_q)
            )
            mstore(
                0x1c00,
                mulmod(
                    mload(0x1320), 12459868075641381822485233712013080087763946065665469821362892189399541605692, f_q
                )
            )
            mstore(
                0x1c20,
                addmod(mload(0xb60), 9428374796197893399761172033244195000784418334750564522335311997176266889925, f_q)
            )
            mstore(
                0x1c40,
                mulmod(
                    mload(0x1320), 12562571400845953139885120066983392294851269266041089223701347829190217414825, f_q
                )
            )
            mstore(
                0x1c60,
                addmod(mload(0xb60), 9325671470993322082361285678273882793697095134374945119996856357385591080792, f_q)
            )
            mstore(
                0x1c80,
                mulmod(
                    mload(0x1320), 16038300751658239075779628684257016433412502747804121525056508685985277092575, f_q
                )
            )
            mstore(
                0x1ca0,
                addmod(mload(0xb60), 5849942120181036146466777061000258655135861652611912818641695500590531403042, f_q)
            )
            mstore(
                0x1cc0,
                mulmod(
                    mload(0x1320), 17665522928519859765452767154433594409738037332395989540221744312194874941704, f_q
                )
            )
            mstore(
                0x1ce0,
                addmod(mload(0xb60), 4222719943319415456793638590823680678810327068020044803476459874380933553913, f_q)
            )
            mstore(
                0x1d00,
                mulmod(mload(0x1320), 6955697244493336113861667751840378876927906302623587437721024018233754910398, f_q)
            )
            mstore(
                0x1d20,
                addmod(mload(0xb60), 14932545627345939108384737993416896211620458097792446905977180168342053585219, f_q)
            )
            mstore(
                0x1d40,
                mulmod(mload(0x1320), 1918679275621049296283934091410967415474987212511681231948800935495808101054, f_q)
            )
            mstore(
                0x1d60,
                addmod(mload(0xb60), 19969563596218225925962471653846307673073377187904353111749403251080000394563, f_q)
            )
            mstore(
                0x1d80,
                mulmod(
                    mload(0x1320), 13498745591877810872211159461644682954739332524336278910448604883789771736885, f_q
                )
            )
            mstore(
                0x1da0,
                addmod(mload(0xb60), 8389497279961464350035246283612592133809031876079755433249599302786036758732, f_q)
            )
            mstore(
                0x1dc0,
                mulmod(mload(0x1320), 6604851689411953560355663038203889299997924520355363678860500374111951937637, f_q)
            )
            mstore(
                0x1de0,
                addmod(mload(0xb60), 15283391182427321661890742707053385788550439880060670664837703812463856557980, f_q)
            )
            mstore(
                0x1e00,
                mulmod(
                    mload(0x1320), 20345677989844117909528750049476969581182118546166966482506114734614108237981, f_q
                )
            )
            mstore(
                0x1e20,
                addmod(mload(0xb60), 1542564881995157312717655695780305507366245854249067861192089451961700257636, f_q)
            )
            mstore(
                0x1e40,
                mulmod(
                    mload(0x1320), 11244009323710436498447061620026171700033960328162115124806024297270121927878, f_q
                )
            )
            mstore(
                0x1e60,
                addmod(mload(0xb60), 10644233548128838723799344125231103388514404072253919218892179889305686567739, f_q)
            )
            mstore(
                0x1e80,
                mulmod(mload(0x1320), 790608022292213379425324383664216541739009722347092850716054055768832299157, f_q)
            )
            mstore(
                0x1ea0,
                addmod(mload(0xb60), 21097634849547061842821081361593058546809354678068941492982150130806976196460, f_q)
            )
            mstore(
                0x1ec0,
                mulmod(
                    mload(0x1320), 13894403229372218245111098554468346933152618215322268934207074514797092422856, f_q
                )
            )
            mstore(
                0x1ee0,
                addmod(mload(0xb60), 7993839642467056977135307190788928155395746185093765409491129671778716072761, f_q)
            )
            mstore(
                0x1f00,
                mulmod(mload(0x1320), 5289443209903185443361862148540090689648485914368835830972895623576469023722, f_q)
            )
            mstore(
                0x1f20,
                addmod(mload(0xb60), 16598799661936089778884543596717184398899878486047198512725308562999339471895, f_q)
            )
            mstore(
                0x1f40,
                mulmod(
                    mload(0x1320), 19715528266218439644661892824912275086257866064695767122686506494361332681035, f_q
                )
            )
            mstore(
                0x1f60,
                addmod(mload(0xb60), 2172714605620835577584512920345000002290498335720267221011697692214475814582, f_q)
            )
            mstore(
                0x1f80,
                mulmod(
                    mload(0x1320), 15161189183906287273290738379431332336600234154579306802151507052820126345529, f_q
                )
            )
            mstore(
                0x1fa0,
                addmod(mload(0xb60), 6727053687932987948955667365825942751948130245836727541546697133755682150088, f_q)
            )
            mstore(
                0x1fc0,
                mulmod(
                    mload(0x1320), 12456424076401232823832128238027368612265814450984711658287606686035629293382, f_q
                )
            )
            mstore(
                0x1fe0,
                addmod(mload(0xb60), 9431818795438042398414277507229906476282549949431322685410597500540179202235, f_q)
            )
            mstore(
                0x2000,
                mulmod(mload(0x1320), 557567375339945239933617516585967620814823575807691402619711360028043331811, f_q)
            )
            mstore(
                0x2020,
                addmod(mload(0xb60), 21330675496499329982312788228671307467733540824608342941078492826547765163806, f_q)
            )
            mstore(
                0x2040,
                mulmod(mload(0x1320), 3675353143102618619098608207619541954347747556257261634661810167705798540391, f_q)
            )
            mstore(
                0x2060,
                addmod(mload(0xb60), 18212889728736656603147797537637733134200616844158772709036394018870009955226, f_q)
            )
            mstore(
                0x2080,
                mulmod(
                    mload(0x1320), 16611719114775828483319365659907682366622074960672212059891361227499450055959, f_q
                )
            )
            mstore(
                0x20a0,
                addmod(mload(0xb60), 5276523757063446738927040085349592721926289439743822283806842959076358439658, f_q)
            )
            mstore(
                0x20c0,
                mulmod(
                    mload(0x1320), 16386136101309958540926610099404767784529741901845901994660986029617143477017, f_q
                )
            )
            mstore(
                0x20e0,
                addmod(mload(0xb60), 5502106770529316681319795645852507304018622498570132349037218156958665018600, f_q)
            )
            mstore(
                0x2100,
                mulmod(mload(0x1320), 4509404676247677387317362072810231899718070082381452255950861037254608304934, f_q)
            )
            mstore(
                0x2120,
                addmod(mload(0xb60), 17378838195591597834929043672447043188830294318034582087747343149321200190683, f_q)
            )
            mstore(
                0x2140,
                mulmod(
                    mload(0x1320), 16810138474166795540944740696920121481076613636731046381068745586671284628566, f_q
                )
            )
            mstore(
                0x2160,
                addmod(mload(0xb60), 5078104397672479681301665048337153607471750763684987962629458599904523867051, f_q)
            )
            mstore(
                0x2180,
                mulmod(mload(0x1320), 6866457077948847028333856457654941632900463970069876241424363695212127143359, f_q)
            )
            mstore(
                0x21a0,
                addmod(mload(0xb60), 15021785793890428193912549287602333455647900430346158102273840491363681352258, f_q)
            )
            mstore(
                0x21c0,
                mulmod(
                    mload(0x1320), 15050098906272869114113753879341673724544293065073132019915594147673843274264, f_q
                )
            )
            mstore(
                0x21e0,
                addmod(mload(0xb60), 6838143965566406108132651865915601364004071335342902323782610038901965221353, f_q)
            )
            mstore(
                0x2200,
                mulmod(
                    mload(0x1320), 20169013865622130318472103510465966222180994822334426398191891983290742724178, f_q
                )
            )
            mstore(
                0x2220,
                addmod(mload(0xb60), 1719229006217144903774302234791308866367369578081607945506312203285065771439, f_q)
            )
            {
                let prod := mload(0x1360)

                prod := mulmod(mload(0x13a0), prod, f_q)
                mstore(0x2240, prod)

                prod := mulmod(mload(0x13e0), prod, f_q)
                mstore(0x2260, prod)

                prod := mulmod(mload(0x1420), prod, f_q)
                mstore(0x2280, prod)

                prod := mulmod(mload(0x1460), prod, f_q)
                mstore(0x22a0, prod)

                prod := mulmod(mload(0x14a0), prod, f_q)
                mstore(0x22c0, prod)

                prod := mulmod(mload(0x14e0), prod, f_q)
                mstore(0x22e0, prod)

                prod := mulmod(mload(0x1520), prod, f_q)
                mstore(0x2300, prod)

                prod := mulmod(mload(0x1560), prod, f_q)
                mstore(0x2320, prod)

                prod := mulmod(mload(0x15a0), prod, f_q)
                mstore(0x2340, prod)

                prod := mulmod(mload(0x15e0), prod, f_q)
                mstore(0x2360, prod)

                prod := mulmod(mload(0x1620), prod, f_q)
                mstore(0x2380, prod)

                prod := mulmod(mload(0x1660), prod, f_q)
                mstore(0x23a0, prod)

                prod := mulmod(mload(0x16a0), prod, f_q)
                mstore(0x23c0, prod)

                prod := mulmod(mload(0x16e0), prod, f_q)
                mstore(0x23e0, prod)

                prod := mulmod(mload(0x1720), prod, f_q)
                mstore(0x2400, prod)

                prod := mulmod(mload(0x1760), prod, f_q)
                mstore(0x2420, prod)

                prod := mulmod(mload(0x17a0), prod, f_q)
                mstore(0x2440, prod)

                prod := mulmod(mload(0x17e0), prod, f_q)
                mstore(0x2460, prod)

                prod := mulmod(mload(0x1820), prod, f_q)
                mstore(0x2480, prod)

                prod := mulmod(mload(0x1860), prod, f_q)
                mstore(0x24a0, prod)

                prod := mulmod(mload(0x18a0), prod, f_q)
                mstore(0x24c0, prod)

                prod := mulmod(mload(0x18e0), prod, f_q)
                mstore(0x24e0, prod)

                prod := mulmod(mload(0x1920), prod, f_q)
                mstore(0x2500, prod)

                prod := mulmod(mload(0x1960), prod, f_q)
                mstore(0x2520, prod)

                prod := mulmod(mload(0x19a0), prod, f_q)
                mstore(0x2540, prod)

                prod := mulmod(mload(0x19e0), prod, f_q)
                mstore(0x2560, prod)

                prod := mulmod(mload(0x1a20), prod, f_q)
                mstore(0x2580, prod)

                prod := mulmod(mload(0x1a60), prod, f_q)
                mstore(0x25a0, prod)

                prod := mulmod(mload(0x1aa0), prod, f_q)
                mstore(0x25c0, prod)

                prod := mulmod(mload(0x1ae0), prod, f_q)
                mstore(0x25e0, prod)

                prod := mulmod(mload(0x1b20), prod, f_q)
                mstore(0x2600, prod)

                prod := mulmod(mload(0x1b60), prod, f_q)
                mstore(0x2620, prod)

                prod := mulmod(mload(0x1ba0), prod, f_q)
                mstore(0x2640, prod)

                prod := mulmod(mload(0x1be0), prod, f_q)
                mstore(0x2660, prod)

                prod := mulmod(mload(0x1c20), prod, f_q)
                mstore(0x2680, prod)

                prod := mulmod(mload(0x1c60), prod, f_q)
                mstore(0x26a0, prod)

                prod := mulmod(mload(0x1ca0), prod, f_q)
                mstore(0x26c0, prod)

                prod := mulmod(mload(0x1ce0), prod, f_q)
                mstore(0x26e0, prod)

                prod := mulmod(mload(0x1d20), prod, f_q)
                mstore(0x2700, prod)

                prod := mulmod(mload(0x1d60), prod, f_q)
                mstore(0x2720, prod)

                prod := mulmod(mload(0x1da0), prod, f_q)
                mstore(0x2740, prod)

                prod := mulmod(mload(0x1de0), prod, f_q)
                mstore(0x2760, prod)

                prod := mulmod(mload(0x1e20), prod, f_q)
                mstore(0x2780, prod)

                prod := mulmod(mload(0x1e60), prod, f_q)
                mstore(0x27a0, prod)

                prod := mulmod(mload(0x1ea0), prod, f_q)
                mstore(0x27c0, prod)

                prod := mulmod(mload(0x1ee0), prod, f_q)
                mstore(0x27e0, prod)

                prod := mulmod(mload(0x1f20), prod, f_q)
                mstore(0x2800, prod)

                prod := mulmod(mload(0x1f60), prod, f_q)
                mstore(0x2820, prod)

                prod := mulmod(mload(0x1fa0), prod, f_q)
                mstore(0x2840, prod)

                prod := mulmod(mload(0x1fe0), prod, f_q)
                mstore(0x2860, prod)

                prod := mulmod(mload(0x2020), prod, f_q)
                mstore(0x2880, prod)

                prod := mulmod(mload(0x2060), prod, f_q)
                mstore(0x28a0, prod)

                prod := mulmod(mload(0x20a0), prod, f_q)
                mstore(0x28c0, prod)

                prod := mulmod(mload(0x20e0), prod, f_q)
                mstore(0x28e0, prod)

                prod := mulmod(mload(0x2120), prod, f_q)
                mstore(0x2900, prod)

                prod := mulmod(mload(0x2160), prod, f_q)
                mstore(0x2920, prod)

                prod := mulmod(mload(0x21a0), prod, f_q)
                mstore(0x2940, prod)

                prod := mulmod(mload(0x21e0), prod, f_q)
                mstore(0x2960, prod)

                prod := mulmod(mload(0x2220), prod, f_q)
                mstore(0x2980, prod)

                prod := mulmod(mload(0x1300), prod, f_q)
                mstore(0x29a0, prod)
            }
            mstore(0x29e0, 32)
            mstore(0x2a00, 32)
            mstore(0x2a20, 32)
            mstore(0x2a40, mload(0x29a0))
            mstore(0x2a60, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
            mstore(0x2a80, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
            success := and(eq(staticcall(gas(), 0x5, 0x29e0, 0xc0, 0x29c0, 0x20), 1), success)
            {
                let inv := mload(0x29c0)
                let v

                v := mload(0x1300)
                mstore(4864, mulmod(mload(0x2980), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2220)
                mstore(8736, mulmod(mload(0x2960), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x21e0)
                mstore(8672, mulmod(mload(0x2940), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x21a0)
                mstore(8608, mulmod(mload(0x2920), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2160)
                mstore(8544, mulmod(mload(0x2900), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2120)
                mstore(8480, mulmod(mload(0x28e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x20e0)
                mstore(8416, mulmod(mload(0x28c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x20a0)
                mstore(8352, mulmod(mload(0x28a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2060)
                mstore(8288, mulmod(mload(0x2880), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2020)
                mstore(8224, mulmod(mload(0x2860), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1fe0)
                mstore(8160, mulmod(mload(0x2840), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1fa0)
                mstore(8096, mulmod(mload(0x2820), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1f60)
                mstore(8032, mulmod(mload(0x2800), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1f20)
                mstore(7968, mulmod(mload(0x27e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1ee0)
                mstore(7904, mulmod(mload(0x27c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1ea0)
                mstore(7840, mulmod(mload(0x27a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1e60)
                mstore(7776, mulmod(mload(0x2780), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1e20)
                mstore(7712, mulmod(mload(0x2760), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1de0)
                mstore(7648, mulmod(mload(0x2740), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1da0)
                mstore(7584, mulmod(mload(0x2720), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1d60)
                mstore(7520, mulmod(mload(0x2700), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1d20)
                mstore(7456, mulmod(mload(0x26e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1ce0)
                mstore(7392, mulmod(mload(0x26c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1ca0)
                mstore(7328, mulmod(mload(0x26a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1c60)
                mstore(7264, mulmod(mload(0x2680), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1c20)
                mstore(7200, mulmod(mload(0x2660), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1be0)
                mstore(7136, mulmod(mload(0x2640), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1ba0)
                mstore(7072, mulmod(mload(0x2620), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1b60)
                mstore(7008, mulmod(mload(0x2600), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1b20)
                mstore(6944, mulmod(mload(0x25e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1ae0)
                mstore(6880, mulmod(mload(0x25c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1aa0)
                mstore(6816, mulmod(mload(0x25a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1a60)
                mstore(6752, mulmod(mload(0x2580), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1a20)
                mstore(6688, mulmod(mload(0x2560), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x19e0)
                mstore(6624, mulmod(mload(0x2540), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x19a0)
                mstore(6560, mulmod(mload(0x2520), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1960)
                mstore(6496, mulmod(mload(0x2500), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1920)
                mstore(6432, mulmod(mload(0x24e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x18e0)
                mstore(6368, mulmod(mload(0x24c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x18a0)
                mstore(6304, mulmod(mload(0x24a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1860)
                mstore(6240, mulmod(mload(0x2480), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1820)
                mstore(6176, mulmod(mload(0x2460), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x17e0)
                mstore(6112, mulmod(mload(0x2440), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x17a0)
                mstore(6048, mulmod(mload(0x2420), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1760)
                mstore(5984, mulmod(mload(0x2400), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1720)
                mstore(5920, mulmod(mload(0x23e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x16e0)
                mstore(5856, mulmod(mload(0x23c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x16a0)
                mstore(5792, mulmod(mload(0x23a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1660)
                mstore(5728, mulmod(mload(0x2380), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1620)
                mstore(5664, mulmod(mload(0x2360), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x15e0)
                mstore(5600, mulmod(mload(0x2340), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x15a0)
                mstore(5536, mulmod(mload(0x2320), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1560)
                mstore(5472, mulmod(mload(0x2300), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1520)
                mstore(5408, mulmod(mload(0x22e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x14e0)
                mstore(5344, mulmod(mload(0x22c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x14a0)
                mstore(5280, mulmod(mload(0x22a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1460)
                mstore(5216, mulmod(mload(0x2280), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1420)
                mstore(5152, mulmod(mload(0x2260), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x13e0)
                mstore(5088, mulmod(mload(0x2240), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x13a0)
                mstore(5024, mulmod(mload(0x1360), inv, f_q))
                inv := mulmod(v, inv, f_q)
                mstore(0x1360, inv)
            }
            mstore(0x2aa0, mulmod(mload(0x1340), mload(0x1360), f_q))
            mstore(0x2ac0, mulmod(mload(0x1380), mload(0x13a0), f_q))
            mstore(0x2ae0, mulmod(mload(0x13c0), mload(0x13e0), f_q))
            mstore(0x2b00, mulmod(mload(0x1400), mload(0x1420), f_q))
            mstore(0x2b20, mulmod(mload(0x1440), mload(0x1460), f_q))
            mstore(0x2b40, mulmod(mload(0x1480), mload(0x14a0), f_q))
            mstore(0x2b60, mulmod(mload(0x14c0), mload(0x14e0), f_q))
            mstore(0x2b80, mulmod(mload(0x1500), mload(0x1520), f_q))
            mstore(0x2ba0, mulmod(mload(0x1540), mload(0x1560), f_q))
            mstore(0x2bc0, mulmod(mload(0x1580), mload(0x15a0), f_q))
            mstore(0x2be0, mulmod(mload(0x15c0), mload(0x15e0), f_q))
            mstore(0x2c00, mulmod(mload(0x1600), mload(0x1620), f_q))
            mstore(0x2c20, mulmod(mload(0x1640), mload(0x1660), f_q))
            mstore(0x2c40, mulmod(mload(0x1680), mload(0x16a0), f_q))
            mstore(0x2c60, mulmod(mload(0x16c0), mload(0x16e0), f_q))
            mstore(0x2c80, mulmod(mload(0x1700), mload(0x1720), f_q))
            mstore(0x2ca0, mulmod(mload(0x1740), mload(0x1760), f_q))
            mstore(0x2cc0, mulmod(mload(0x1780), mload(0x17a0), f_q))
            mstore(0x2ce0, mulmod(mload(0x17c0), mload(0x17e0), f_q))
            mstore(0x2d00, mulmod(mload(0x1800), mload(0x1820), f_q))
            mstore(0x2d20, mulmod(mload(0x1840), mload(0x1860), f_q))
            mstore(0x2d40, mulmod(mload(0x1880), mload(0x18a0), f_q))
            mstore(0x2d60, mulmod(mload(0x18c0), mload(0x18e0), f_q))
            mstore(0x2d80, mulmod(mload(0x1900), mload(0x1920), f_q))
            mstore(0x2da0, mulmod(mload(0x1940), mload(0x1960), f_q))
            mstore(0x2dc0, mulmod(mload(0x1980), mload(0x19a0), f_q))
            mstore(0x2de0, mulmod(mload(0x19c0), mload(0x19e0), f_q))
            mstore(0x2e00, mulmod(mload(0x1a00), mload(0x1a20), f_q))
            mstore(0x2e20, mulmod(mload(0x1a40), mload(0x1a60), f_q))
            mstore(0x2e40, mulmod(mload(0x1a80), mload(0x1aa0), f_q))
            mstore(0x2e60, mulmod(mload(0x1ac0), mload(0x1ae0), f_q))
            mstore(0x2e80, mulmod(mload(0x1b00), mload(0x1b20), f_q))
            mstore(0x2ea0, mulmod(mload(0x1b40), mload(0x1b60), f_q))
            mstore(0x2ec0, mulmod(mload(0x1b80), mload(0x1ba0), f_q))
            mstore(0x2ee0, mulmod(mload(0x1bc0), mload(0x1be0), f_q))
            mstore(0x2f00, mulmod(mload(0x1c00), mload(0x1c20), f_q))
            mstore(0x2f20, mulmod(mload(0x1c40), mload(0x1c60), f_q))
            mstore(0x2f40, mulmod(mload(0x1c80), mload(0x1ca0), f_q))
            mstore(0x2f60, mulmod(mload(0x1cc0), mload(0x1ce0), f_q))
            mstore(0x2f80, mulmod(mload(0x1d00), mload(0x1d20), f_q))
            mstore(0x2fa0, mulmod(mload(0x1d40), mload(0x1d60), f_q))
            mstore(0x2fc0, mulmod(mload(0x1d80), mload(0x1da0), f_q))
            mstore(0x2fe0, mulmod(mload(0x1dc0), mload(0x1de0), f_q))
            mstore(0x3000, mulmod(mload(0x1e00), mload(0x1e20), f_q))
            mstore(0x3020, mulmod(mload(0x1e40), mload(0x1e60), f_q))
            mstore(0x3040, mulmod(mload(0x1e80), mload(0x1ea0), f_q))
            mstore(0x3060, mulmod(mload(0x1ec0), mload(0x1ee0), f_q))
            mstore(0x3080, mulmod(mload(0x1f00), mload(0x1f20), f_q))
            mstore(0x30a0, mulmod(mload(0x1f40), mload(0x1f60), f_q))
            mstore(0x30c0, mulmod(mload(0x1f80), mload(0x1fa0), f_q))
            mstore(0x30e0, mulmod(mload(0x1fc0), mload(0x1fe0), f_q))
            mstore(0x3100, mulmod(mload(0x2000), mload(0x2020), f_q))
            mstore(0x3120, mulmod(mload(0x2040), mload(0x2060), f_q))
            mstore(0x3140, mulmod(mload(0x2080), mload(0x20a0), f_q))
            mstore(0x3160, mulmod(mload(0x20c0), mload(0x20e0), f_q))
            mstore(0x3180, mulmod(mload(0x2100), mload(0x2120), f_q))
            mstore(0x31a0, mulmod(mload(0x2140), mload(0x2160), f_q))
            mstore(0x31c0, mulmod(mload(0x2180), mload(0x21a0), f_q))
            mstore(0x31e0, mulmod(mload(0x21c0), mload(0x21e0), f_q))
            mstore(0x3200, mulmod(mload(0x2200), mload(0x2220), f_q))
            {
                let result := mulmod(mload(0x2b80), mload(0xa0), f_q)
                result := addmod(mulmod(mload(0x2ba0), mload(0xc0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2bc0), mload(0xe0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2be0), mload(0x100), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2c00), mload(0x120), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2c20), mload(0x140), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2c40), mload(0x160), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2c60), mload(0x180), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2c80), mload(0x1a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2ca0), mload(0x1c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2cc0), mload(0x1e0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2ce0), mload(0x200), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2d00), mload(0x220), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2d20), mload(0x240), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2d40), mload(0x260), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2d60), mload(0x280), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2d80), mload(0x2a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2da0), mload(0x2c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2dc0), mload(0x2e0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2de0), mload(0x300), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2e00), mload(0x320), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2e20), mload(0x340), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2e40), mload(0x360), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2e60), mload(0x380), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2e80), mload(0x3a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2ea0), mload(0x3c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2ec0), mload(0x3e0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2ee0), mload(0x400), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2f00), mload(0x420), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2f20), mload(0x440), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2f40), mload(0x460), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2f60), mload(0x480), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2f80), mload(0x4a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2fa0), mload(0x4c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2fc0), mload(0x4e0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2fe0), mload(0x500), f_q), result, f_q)
                result := addmod(mulmod(mload(0x3000), mload(0x520), f_q), result, f_q)
                result := addmod(mulmod(mload(0x3020), mload(0x540), f_q), result, f_q)
                result := addmod(mulmod(mload(0x3040), mload(0x560), f_q), result, f_q)
                result := addmod(mulmod(mload(0x3060), mload(0x580), f_q), result, f_q)
                result := addmod(mulmod(mload(0x3080), mload(0x5a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x30a0), mload(0x5c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x30c0), mload(0x5e0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x30e0), mload(0x600), f_q), result, f_q)
                result := addmod(mulmod(mload(0x3100), mload(0x620), f_q), result, f_q)
                result := addmod(mulmod(mload(0x3120), mload(0x640), f_q), result, f_q)
                result := addmod(mulmod(mload(0x3140), mload(0x660), f_q), result, f_q)
                result := addmod(mulmod(mload(0x3160), mload(0x680), f_q), result, f_q)
                result := addmod(mulmod(mload(0x3180), mload(0x6a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x31a0), mload(0x6c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x31c0), mload(0x6e0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x31e0), mload(0x700), f_q), result, f_q)
                result := addmod(mulmod(mload(0x3200), mload(0x720), f_q), result, f_q)
                mstore(12832, result)
            }
            mstore(0x3240, mulmod(mload(0xbe0), mload(0xbc0), f_q))
            mstore(0x3260, addmod(mload(0xba0), mload(0x3240), f_q))
            mstore(0x3280, addmod(mload(0x3260), sub(f_q, mload(0xc00)), f_q))
            mstore(0x32a0, mulmod(mload(0x3280), mload(0xc60), f_q))
            mstore(0x32c0, mulmod(mload(0xa00), mload(0x32a0), f_q))
            mstore(0x32e0, addmod(1, sub(f_q, mload(0xd20)), f_q))
            mstore(0x3300, mulmod(mload(0x32e0), mload(0x2b80), f_q))
            mstore(0x3320, addmod(mload(0x32c0), mload(0x3300), f_q))
            mstore(0x3340, mulmod(mload(0xa00), mload(0x3320), f_q))
            mstore(0x3360, mulmod(mload(0xd20), mload(0xd20), f_q))
            mstore(0x3380, addmod(mload(0x3360), sub(f_q, mload(0xd20)), f_q))
            mstore(0x33a0, mulmod(mload(0x3380), mload(0x2aa0), f_q))
            mstore(0x33c0, addmod(mload(0x3340), mload(0x33a0), f_q))
            mstore(0x33e0, mulmod(mload(0xa00), mload(0x33c0), f_q))
            mstore(0x3400, addmod(1, sub(f_q, mload(0x2aa0)), f_q))
            mstore(0x3420, addmod(mload(0x2ac0), mload(0x2ae0), f_q))
            mstore(0x3440, addmod(mload(0x3420), mload(0x2b00), f_q))
            mstore(0x3460, addmod(mload(0x3440), mload(0x2b20), f_q))
            mstore(0x3480, addmod(mload(0x3460), mload(0x2b40), f_q))
            mstore(0x34a0, addmod(mload(0x3480), mload(0x2b60), f_q))
            mstore(0x34c0, addmod(mload(0x3400), sub(f_q, mload(0x34a0)), f_q))
            mstore(0x34e0, mulmod(mload(0xcc0), mload(0x880), f_q))
            mstore(0x3500, addmod(mload(0xc20), mload(0x34e0), f_q))
            mstore(0x3520, addmod(mload(0x3500), mload(0x8e0), f_q))
            mstore(0x3540, mulmod(mload(0xce0), mload(0x880), f_q))
            mstore(0x3560, addmod(mload(0xba0), mload(0x3540), f_q))
            mstore(0x3580, addmod(mload(0x3560), mload(0x8e0), f_q))
            mstore(0x35a0, mulmod(mload(0x3580), mload(0x3520), f_q))
            mstore(0x35c0, mulmod(mload(0xd00), mload(0x880), f_q))
            mstore(0x35e0, addmod(mload(0x3220), mload(0x35c0), f_q))
            mstore(0x3600, addmod(mload(0x35e0), mload(0x8e0), f_q))
            mstore(0x3620, mulmod(mload(0x3600), mload(0x35a0), f_q))
            mstore(0x3640, mulmod(mload(0x3620), mload(0xd40), f_q))
            mstore(0x3660, mulmod(1, mload(0x880), f_q))
            mstore(0x3680, mulmod(mload(0xb60), mload(0x3660), f_q))
            mstore(0x36a0, addmod(mload(0xc20), mload(0x3680), f_q))
            mstore(0x36c0, addmod(mload(0x36a0), mload(0x8e0), f_q))
            mstore(
                0x36e0,
                mulmod(4131629893567559867359510883348571134090853742863529169391034518566172092834, mload(0x880), f_q)
            )
            mstore(0x3700, mulmod(mload(0xb60), mload(0x36e0), f_q))
            mstore(0x3720, addmod(mload(0xba0), mload(0x3700), f_q))
            mstore(0x3740, addmod(mload(0x3720), mload(0x8e0), f_q))
            mstore(0x3760, mulmod(mload(0x3740), mload(0x36c0), f_q))
            mstore(
                0x3780,
                mulmod(8910878055287538404433155982483128285667088683464058436815641868457422632747, mload(0x880), f_q)
            )
            mstore(0x37a0, mulmod(mload(0xb60), mload(0x3780), f_q))
            mstore(0x37c0, addmod(mload(0x3220), mload(0x37a0), f_q))
            mstore(0x37e0, addmod(mload(0x37c0), mload(0x8e0), f_q))
            mstore(0x3800, mulmod(mload(0x37e0), mload(0x3760), f_q))
            mstore(0x3820, mulmod(mload(0x3800), mload(0xd20), f_q))
            mstore(0x3840, addmod(mload(0x3640), sub(f_q, mload(0x3820)), f_q))
            mstore(0x3860, mulmod(mload(0x3840), mload(0x34c0), f_q))
            mstore(0x3880, addmod(mload(0x33e0), mload(0x3860), f_q))
            mstore(0x38a0, mulmod(mload(0xa00), mload(0x3880), f_q))
            mstore(0x38c0, addmod(1, sub(f_q, mload(0xd60)), f_q))
            mstore(0x38e0, mulmod(mload(0x38c0), mload(0x2b80), f_q))
            mstore(0x3900, addmod(mload(0x38a0), mload(0x38e0), f_q))
            mstore(0x3920, mulmod(mload(0xa00), mload(0x3900), f_q))
            mstore(0x3940, mulmod(mload(0xd60), mload(0xd60), f_q))
            mstore(0x3960, addmod(mload(0x3940), sub(f_q, mload(0xd60)), f_q))
            mstore(0x3980, mulmod(mload(0x3960), mload(0x2aa0), f_q))
            mstore(0x39a0, addmod(mload(0x3920), mload(0x3980), f_q))
            mstore(0x39c0, mulmod(mload(0xa00), mload(0x39a0), f_q))
            mstore(0x39e0, addmod(mload(0xda0), mload(0x880), f_q))
            mstore(0x3a00, mulmod(mload(0x39e0), mload(0xd80), f_q))
            mstore(0x3a20, addmod(mload(0xde0), mload(0x8e0), f_q))
            mstore(0x3a40, mulmod(mload(0x3a20), mload(0x3a00), f_q))
            mstore(0x3a60, mulmod(mload(0xba0), mload(0xc80), f_q))
            mstore(0x3a80, addmod(mload(0x3a60), mload(0x880), f_q))
            mstore(0x3aa0, mulmod(mload(0x3a80), mload(0xd60), f_q))
            mstore(0x3ac0, addmod(mload(0xc40), mload(0x8e0), f_q))
            mstore(0x3ae0, mulmod(mload(0x3ac0), mload(0x3aa0), f_q))
            mstore(0x3b00, addmod(mload(0x3a40), sub(f_q, mload(0x3ae0)), f_q))
            mstore(0x3b20, mulmod(mload(0x3b00), mload(0x34c0), f_q))
            mstore(0x3b40, addmod(mload(0x39c0), mload(0x3b20), f_q))
            mstore(0x3b60, mulmod(mload(0xa00), mload(0x3b40), f_q))
            mstore(0x3b80, addmod(mload(0xda0), sub(f_q, mload(0xde0)), f_q))
            mstore(0x3ba0, mulmod(mload(0x3b80), mload(0x2b80), f_q))
            mstore(0x3bc0, addmod(mload(0x3b60), mload(0x3ba0), f_q))
            mstore(0x3be0, mulmod(mload(0xa00), mload(0x3bc0), f_q))
            mstore(0x3c00, mulmod(mload(0x3b80), mload(0x34c0), f_q))
            mstore(0x3c20, addmod(mload(0xda0), sub(f_q, mload(0xdc0)), f_q))
            mstore(0x3c40, mulmod(mload(0x3c20), mload(0x3c00), f_q))
            mstore(0x3c60, addmod(mload(0x3be0), mload(0x3c40), f_q))
            mstore(0x3c80, mulmod(mload(0x12e0), mload(0x12e0), f_q))
            mstore(0x3ca0, mulmod(mload(0x3c80), mload(0x12e0), f_q))
            mstore(0x3cc0, mulmod(mload(0x3ca0), mload(0x12e0), f_q))
            mstore(0x3ce0, mulmod(1, mload(0x12e0), f_q))
            mstore(0x3d00, mulmod(1, mload(0x3c80), f_q))
            mstore(0x3d20, mulmod(1, mload(0x3ca0), f_q))
            mstore(0x3d40, mulmod(mload(0x3c60), mload(0x1300), f_q))
            mstore(0x3d60, mulmod(mload(0x1020), mload(0xb60), f_q))
            mstore(0x3d80, mulmod(mload(0x3d60), mload(0xb60), f_q))
            mstore(
                0x3da0,
                mulmod(mload(0xb60), 9741553891420464328295280489650144566903017206473301385034033384879943874347, f_q)
            )
            mstore(0x3dc0, addmod(mload(0xf20), sub(f_q, mload(0x3da0)), f_q))
            mstore(0x3de0, mulmod(mload(0xb60), 1, f_q))
            mstore(0x3e00, addmod(mload(0xf20), sub(f_q, mload(0x3de0)), f_q))
            mstore(
                0x3e20,
                mulmod(mload(0xb60), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            mstore(0x3e40, addmod(mload(0xf20), sub(f_q, mload(0x3e20)), f_q))
            mstore(
                0x3e60,
                mulmod(mload(0xb60), 11211301017135681023579411905410872569206244553457844956874280139879520583390, f_q)
            )
            mstore(0x3e80, addmod(mload(0xf20), sub(f_q, mload(0x3e60)), f_q))
            mstore(
                0x3ea0,
                mulmod(mload(0xb60), 3615478808282855240548287271348143516886772452944084747768312988864436725401, f_q)
            )
            mstore(0x3ec0, addmod(mload(0xf20), sub(f_q, mload(0x3ea0)), f_q))
            mstore(
                0x3ee0,
                mulmod(
                    13213688729882003894512633350385593288217014177373218494356903340348818451480, mload(0x3d60), f_q
                )
            )
            mstore(0x3f00, mulmod(mload(0x3ee0), 1, f_q))
            {
                let result := mulmod(mload(0xf20), mload(0x3ee0), f_q)
                result := addmod(mulmod(mload(0xb60), sub(f_q, mload(0x3f00)), f_q), result, f_q)
                mstore(16160, result)
            }
            mstore(
                0x3f40,
                mulmod(8207090019724696496350398458716998472718344609680392612601596849934418295470, mload(0x3d60), f_q)
            )
            mstore(
                0x3f60,
                mulmod(mload(0x3f40), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            {
                let result := mulmod(mload(0xf20), mload(0x3f40), f_q)
                result := addmod(mulmod(mload(0xb60), sub(f_q, mload(0x3f60)), f_q), result, f_q)
                mstore(16256, result)
            }
            mstore(
                0x3fa0,
                mulmod(7391709068497399131897422873231908718558236401035363928063603272120120747483, mload(0x3d60), f_q)
            )
            mstore(
                0x3fc0,
                mulmod(
                    mload(0x3fa0), 11211301017135681023579411905410872569206244553457844956874280139879520583390, f_q
                )
            )
            {
                let result := mulmod(mload(0xf20), mload(0x3fa0), f_q)
                result := addmod(mulmod(mload(0xb60), sub(f_q, mload(0x3fc0)), f_q), result, f_q)
                mstore(16352, result)
            }
            mstore(
                0x4000,
                mulmod(
                    19036273796805830823244991598792794567595348772040298280440552631112242221017, mload(0x3d60), f_q
                )
            )
            mstore(
                0x4020,
                mulmod(mload(0x4000), 3615478808282855240548287271348143516886772452944084747768312988864436725401, f_q)
            )
            {
                let result := mulmod(mload(0xf20), mload(0x4000), f_q)
                result := addmod(mulmod(mload(0xb60), sub(f_q, mload(0x4020)), f_q), result, f_q)
                mstore(16448, result)
            }
            mstore(0x4060, mulmod(1, mload(0x3e00), f_q))
            mstore(0x4080, mulmod(mload(0x4060), mload(0x3e40), f_q))
            mstore(0x40a0, mulmod(mload(0x4080), mload(0x3e80), f_q))
            mstore(0x40c0, mulmod(mload(0x40a0), mload(0x3ec0), f_q))
            mstore(
                0x40e0,
                mulmod(13513867906530865119835332133273263211836799082674232843258448413103731898271, mload(0xb60), f_q)
            )
            mstore(0x4100, mulmod(mload(0x40e0), 1, f_q))
            {
                let result := mulmod(mload(0xf20), mload(0x40e0), f_q)
                result := addmod(mulmod(mload(0xb60), sub(f_q, mload(0x4100)), f_q), result, f_q)
                mstore(16672, result)
            }
            mstore(
                0x4140,
                mulmod(8374374965308410102411073611984011876711565317741801500439755773472076597346, mload(0xb60), f_q)
            )
            mstore(
                0x4160,
                mulmod(mload(0x4140), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            {
                let result := mulmod(mload(0xf20), mload(0x4140), f_q)
                result := addmod(mulmod(mload(0xb60), sub(f_q, mload(0x4160)), f_q), result, f_q)
                mstore(16768, result)
            }
            mstore(
                0x41a0,
                mulmod(12146688980418810893951125255607130521645347193942732958664170801695864621271, mload(0xb60), f_q)
            )
            mstore(0x41c0, mulmod(mload(0x41a0), 1, f_q))
            {
                let result := mulmod(mload(0xf20), mload(0x41a0), f_q)
                result := addmod(mulmod(mload(0xb60), sub(f_q, mload(0x41c0)), f_q), result, f_q)
                mstore(16864, result)
            }
            mstore(
                0x4200,
                mulmod(9741553891420464328295280489650144566903017206473301385034033384879943874346, mload(0xb60), f_q)
            )
            mstore(
                0x4220,
                mulmod(mload(0x4200), 9741553891420464328295280489650144566903017206473301385034033384879943874347, f_q)
            )
            {
                let result := mulmod(mload(0xf20), mload(0x4200), f_q)
                result := addmod(mulmod(mload(0xb60), sub(f_q, mload(0x4220)), f_q), result, f_q)
                mstore(16960, result)
            }
            mstore(0x4260, mulmod(mload(0x4060), mload(0x3dc0), f_q))
            {
                let result := mulmod(mload(0xf20), 1, f_q)
                result :=
                    addmod(
                        mulmod(
                            mload(0xb60), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q
                        ),
                        result,
                        f_q
                    )
                mstore(17024, result)
            }
            {
                let prod := mload(0x3f20)

                prod := mulmod(mload(0x3f80), prod, f_q)
                mstore(0x42a0, prod)

                prod := mulmod(mload(0x3fe0), prod, f_q)
                mstore(0x42c0, prod)

                prod := mulmod(mload(0x4040), prod, f_q)
                mstore(0x42e0, prod)

                prod := mulmod(mload(0x4120), prod, f_q)
                mstore(0x4300, prod)

                prod := mulmod(mload(0x4180), prod, f_q)
                mstore(0x4320, prod)

                prod := mulmod(mload(0x4080), prod, f_q)
                mstore(0x4340, prod)

                prod := mulmod(mload(0x41e0), prod, f_q)
                mstore(0x4360, prod)

                prod := mulmod(mload(0x4240), prod, f_q)
                mstore(0x4380, prod)

                prod := mulmod(mload(0x4260), prod, f_q)
                mstore(0x43a0, prod)

                prod := mulmod(mload(0x4280), prod, f_q)
                mstore(0x43c0, prod)

                prod := mulmod(mload(0x4060), prod, f_q)
                mstore(0x43e0, prod)
            }
            mstore(0x4420, 32)
            mstore(0x4440, 32)
            mstore(0x4460, 32)
            mstore(0x4480, mload(0x43e0))
            mstore(0x44a0, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
            mstore(0x44c0, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
            success := and(eq(staticcall(gas(), 0x5, 0x4420, 0xc0, 0x4400, 0x20), 1), success)
            {
                let inv := mload(0x4400)
                let v

                v := mload(0x4060)
                mstore(16480, mulmod(mload(0x43c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x4280)
                mstore(17024, mulmod(mload(0x43a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x4260)
                mstore(16992, mulmod(mload(0x4380), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x4240)
                mstore(16960, mulmod(mload(0x4360), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x41e0)
                mstore(16864, mulmod(mload(0x4340), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x4080)
                mstore(16512, mulmod(mload(0x4320), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x4180)
                mstore(16768, mulmod(mload(0x4300), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x4120)
                mstore(16672, mulmod(mload(0x42e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x4040)
                mstore(16448, mulmod(mload(0x42c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3fe0)
                mstore(16352, mulmod(mload(0x42a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3f80)
                mstore(16256, mulmod(mload(0x3f20), inv, f_q))
                inv := mulmod(v, inv, f_q)
                mstore(0x3f20, inv)
            }
            {
                let result := mload(0x3f20)
                result := addmod(mload(0x3f80), result, f_q)
                result := addmod(mload(0x3fe0), result, f_q)
                result := addmod(mload(0x4040), result, f_q)
                mstore(17632, result)
            }
            mstore(0x4500, mulmod(mload(0x40c0), mload(0x4080), f_q))
            {
                let result := mload(0x4120)
                result := addmod(mload(0x4180), result, f_q)
                mstore(17696, result)
            }
            mstore(0x4540, mulmod(mload(0x40c0), mload(0x4260), f_q))
            {
                let result := mload(0x41e0)
                result := addmod(mload(0x4240), result, f_q)
                mstore(17760, result)
            }
            mstore(0x4580, mulmod(mload(0x40c0), mload(0x4060), f_q))
            {
                let result := mload(0x4280)
                mstore(17824, result)
            }
            {
                let prod := mload(0x44e0)

                prod := mulmod(mload(0x4520), prod, f_q)
                mstore(0x45c0, prod)

                prod := mulmod(mload(0x4560), prod, f_q)
                mstore(0x45e0, prod)

                prod := mulmod(mload(0x45a0), prod, f_q)
                mstore(0x4600, prod)
            }
            mstore(0x4640, 32)
            mstore(0x4660, 32)
            mstore(0x4680, 32)
            mstore(0x46a0, mload(0x4600))
            mstore(0x46c0, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
            mstore(0x46e0, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
            success := and(eq(staticcall(gas(), 0x5, 0x4640, 0xc0, 0x4620, 0x20), 1), success)
            {
                let inv := mload(0x4620)
                let v

                v := mload(0x45a0)
                mstore(17824, mulmod(mload(0x45e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x4560)
                mstore(17760, mulmod(mload(0x45c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x4520)
                mstore(17696, mulmod(mload(0x44e0), inv, f_q))
                inv := mulmod(v, inv, f_q)
                mstore(0x44e0, inv)
            }
            mstore(0x4700, mulmod(mload(0x4500), mload(0x4520), f_q))
            mstore(0x4720, mulmod(mload(0x4540), mload(0x4560), f_q))
            mstore(0x4740, mulmod(mload(0x4580), mload(0x45a0), f_q))
            mstore(0x4760, mulmod(mload(0xe20), mload(0xe20), f_q))
            mstore(0x4780, mulmod(mload(0x4760), mload(0xe20), f_q))
            mstore(0x47a0, mulmod(mload(0x4780), mload(0xe20), f_q))
            mstore(0x47c0, mulmod(mload(0x47a0), mload(0xe20), f_q))
            mstore(0x47e0, mulmod(mload(0x47c0), mload(0xe20), f_q))
            mstore(0x4800, mulmod(mload(0x47e0), mload(0xe20), f_q))
            mstore(0x4820, mulmod(mload(0x4800), mload(0xe20), f_q))
            mstore(0x4840, mulmod(mload(0x4820), mload(0xe20), f_q))
            mstore(0x4860, mulmod(mload(0x4840), mload(0xe20), f_q))
            mstore(0x4880, mulmod(mload(0xe80), mload(0xe80), f_q))
            mstore(0x48a0, mulmod(mload(0x4880), mload(0xe80), f_q))
            mstore(0x48c0, mulmod(mload(0x48a0), mload(0xe80), f_q))
            {
                let result := mulmod(mload(0xba0), mload(0x3f20), f_q)
                result := addmod(mulmod(mload(0xbc0), mload(0x3f80), f_q), result, f_q)
                result := addmod(mulmod(mload(0xbe0), mload(0x3fe0), f_q), result, f_q)
                result := addmod(mulmod(mload(0xc00), mload(0x4040), f_q), result, f_q)
                mstore(18656, result)
            }
            mstore(0x4900, mulmod(mload(0x48e0), mload(0x44e0), f_q))
            mstore(0x4920, mulmod(sub(f_q, mload(0x4900)), 1, f_q))
            mstore(0x4940, mulmod(mload(0x4920), 1, f_q))
            mstore(0x4960, mulmod(1, mload(0x4500), f_q))
            {
                let result := mulmod(mload(0xd20), mload(0x4120), f_q)
                result := addmod(mulmod(mload(0xd40), mload(0x4180), f_q), result, f_q)
                mstore(18816, result)
            }
            mstore(0x49a0, mulmod(mload(0x4980), mload(0x4700), f_q))
            mstore(0x49c0, mulmod(sub(f_q, mload(0x49a0)), 1, f_q))
            mstore(0x49e0, mulmod(mload(0x4960), 1, f_q))
            {
                let result := mulmod(mload(0xd60), mload(0x4120), f_q)
                result := addmod(mulmod(mload(0xd80), mload(0x4180), f_q), result, f_q)
                mstore(18944, result)
            }
            mstore(0x4a20, mulmod(mload(0x4a00), mload(0x4700), f_q))
            mstore(0x4a40, mulmod(sub(f_q, mload(0x4a20)), mload(0xe20), f_q))
            mstore(0x4a60, mulmod(mload(0x4960), mload(0xe20), f_q))
            mstore(0x4a80, addmod(mload(0x49c0), mload(0x4a40), f_q))
            mstore(0x4aa0, mulmod(mload(0x4a80), mload(0xe80), f_q))
            mstore(0x4ac0, mulmod(mload(0x49e0), mload(0xe80), f_q))
            mstore(0x4ae0, mulmod(mload(0x4a60), mload(0xe80), f_q))
            mstore(0x4b00, addmod(mload(0x4940), mload(0x4aa0), f_q))
            mstore(0x4b20, mulmod(1, mload(0x4540), f_q))
            {
                let result := mulmod(mload(0xda0), mload(0x41e0), f_q)
                result := addmod(mulmod(mload(0xdc0), mload(0x4240), f_q), result, f_q)
                mstore(19264, result)
            }
            mstore(0x4b60, mulmod(mload(0x4b40), mload(0x4720), f_q))
            mstore(0x4b80, mulmod(sub(f_q, mload(0x4b60)), 1, f_q))
            mstore(0x4ba0, mulmod(mload(0x4b20), 1, f_q))
            mstore(0x4bc0, mulmod(mload(0x4b80), mload(0x4880), f_q))
            mstore(0x4be0, mulmod(mload(0x4ba0), mload(0x4880), f_q))
            mstore(0x4c00, addmod(mload(0x4b00), mload(0x4bc0), f_q))
            mstore(0x4c20, mulmod(1, mload(0x4580), f_q))
            {
                let result := mulmod(mload(0xde0), mload(0x4280), f_q)
                mstore(19520, result)
            }
            mstore(0x4c60, mulmod(mload(0x4c40), mload(0x4740), f_q))
            mstore(0x4c80, mulmod(sub(f_q, mload(0x4c60)), 1, f_q))
            mstore(0x4ca0, mulmod(mload(0x4c20), 1, f_q))
            {
                let result := mulmod(mload(0xc20), mload(0x4280), f_q)
                mstore(19648, result)
            }
            mstore(0x4ce0, mulmod(mload(0x4cc0), mload(0x4740), f_q))
            mstore(0x4d00, mulmod(sub(f_q, mload(0x4ce0)), mload(0xe20), f_q))
            mstore(0x4d20, mulmod(mload(0x4c20), mload(0xe20), f_q))
            mstore(0x4d40, addmod(mload(0x4c80), mload(0x4d00), f_q))
            {
                let result := mulmod(mload(0xc40), mload(0x4280), f_q)
                mstore(19808, result)
            }
            mstore(0x4d80, mulmod(mload(0x4d60), mload(0x4740), f_q))
            mstore(0x4da0, mulmod(sub(f_q, mload(0x4d80)), mload(0x4760), f_q))
            mstore(0x4dc0, mulmod(mload(0x4c20), mload(0x4760), f_q))
            mstore(0x4de0, addmod(mload(0x4d40), mload(0x4da0), f_q))
            {
                let result := mulmod(mload(0xc60), mload(0x4280), f_q)
                mstore(19968, result)
            }
            mstore(0x4e20, mulmod(mload(0x4e00), mload(0x4740), f_q))
            mstore(0x4e40, mulmod(sub(f_q, mload(0x4e20)), mload(0x4780), f_q))
            mstore(0x4e60, mulmod(mload(0x4c20), mload(0x4780), f_q))
            mstore(0x4e80, addmod(mload(0x4de0), mload(0x4e40), f_q))
            {
                let result := mulmod(mload(0xc80), mload(0x4280), f_q)
                mstore(20128, result)
            }
            mstore(0x4ec0, mulmod(mload(0x4ea0), mload(0x4740), f_q))
            mstore(0x4ee0, mulmod(sub(f_q, mload(0x4ec0)), mload(0x47a0), f_q))
            mstore(0x4f00, mulmod(mload(0x4c20), mload(0x47a0), f_q))
            mstore(0x4f20, addmod(mload(0x4e80), mload(0x4ee0), f_q))
            {
                let result := mulmod(mload(0xcc0), mload(0x4280), f_q)
                mstore(20288, result)
            }
            mstore(0x4f60, mulmod(mload(0x4f40), mload(0x4740), f_q))
            mstore(0x4f80, mulmod(sub(f_q, mload(0x4f60)), mload(0x47c0), f_q))
            mstore(0x4fa0, mulmod(mload(0x4c20), mload(0x47c0), f_q))
            mstore(0x4fc0, addmod(mload(0x4f20), mload(0x4f80), f_q))
            {
                let result := mulmod(mload(0xce0), mload(0x4280), f_q)
                mstore(20448, result)
            }
            mstore(0x5000, mulmod(mload(0x4fe0), mload(0x4740), f_q))
            mstore(0x5020, mulmod(sub(f_q, mload(0x5000)), mload(0x47e0), f_q))
            mstore(0x5040, mulmod(mload(0x4c20), mload(0x47e0), f_q))
            mstore(0x5060, addmod(mload(0x4fc0), mload(0x5020), f_q))
            {
                let result := mulmod(mload(0xd00), mload(0x4280), f_q)
                mstore(20608, result)
            }
            mstore(0x50a0, mulmod(mload(0x5080), mload(0x4740), f_q))
            mstore(0x50c0, mulmod(sub(f_q, mload(0x50a0)), mload(0x4800), f_q))
            mstore(0x50e0, mulmod(mload(0x4c20), mload(0x4800), f_q))
            mstore(0x5100, addmod(mload(0x5060), mload(0x50c0), f_q))
            mstore(0x5120, mulmod(mload(0x3ce0), mload(0x4580), f_q))
            mstore(0x5140, mulmod(mload(0x3d00), mload(0x4580), f_q))
            mstore(0x5160, mulmod(mload(0x3d20), mload(0x4580), f_q))
            {
                let result := mulmod(mload(0x3d40), mload(0x4280), f_q)
                mstore(20864, result)
            }
            mstore(0x51a0, mulmod(mload(0x5180), mload(0x4740), f_q))
            mstore(0x51c0, mulmod(sub(f_q, mload(0x51a0)), mload(0x4820), f_q))
            mstore(0x51e0, mulmod(mload(0x4c20), mload(0x4820), f_q))
            mstore(0x5200, mulmod(mload(0x5120), mload(0x4820), f_q))
            mstore(0x5220, mulmod(mload(0x5140), mload(0x4820), f_q))
            mstore(0x5240, mulmod(mload(0x5160), mload(0x4820), f_q))
            mstore(0x5260, addmod(mload(0x5100), mload(0x51c0), f_q))
            {
                let result := mulmod(mload(0xca0), mload(0x4280), f_q)
                mstore(21120, result)
            }
            mstore(0x52a0, mulmod(mload(0x5280), mload(0x4740), f_q))
            mstore(0x52c0, mulmod(sub(f_q, mload(0x52a0)), mload(0x4840), f_q))
            mstore(0x52e0, mulmod(mload(0x4c20), mload(0x4840), f_q))
            mstore(0x5300, addmod(mload(0x5260), mload(0x52c0), f_q))
            mstore(0x5320, mulmod(mload(0x5300), mload(0x48a0), f_q))
            mstore(0x5340, mulmod(mload(0x4ca0), mload(0x48a0), f_q))
            mstore(0x5360, mulmod(mload(0x4d20), mload(0x48a0), f_q))
            mstore(0x5380, mulmod(mload(0x4dc0), mload(0x48a0), f_q))
            mstore(0x53a0, mulmod(mload(0x4e60), mload(0x48a0), f_q))
            mstore(0x53c0, mulmod(mload(0x4f00), mload(0x48a0), f_q))
            mstore(0x53e0, mulmod(mload(0x4fa0), mload(0x48a0), f_q))
            mstore(0x5400, mulmod(mload(0x5040), mload(0x48a0), f_q))
            mstore(0x5420, mulmod(mload(0x50e0), mload(0x48a0), f_q))
            mstore(0x5440, mulmod(mload(0x51e0), mload(0x48a0), f_q))
            mstore(0x5460, mulmod(mload(0x5200), mload(0x48a0), f_q))
            mstore(0x5480, mulmod(mload(0x5220), mload(0x48a0), f_q))
            mstore(0x54a0, mulmod(mload(0x5240), mload(0x48a0), f_q))
            mstore(0x54c0, mulmod(mload(0x52e0), mload(0x48a0), f_q))
            mstore(0x54e0, addmod(mload(0x4c00), mload(0x5320), f_q))
            mstore(0x5500, mulmod(1, mload(0x40c0), f_q))
            mstore(0x5520, mulmod(1, mload(0xf20), f_q))
            mstore(0x5540, 0x0000000000000000000000000000000000000000000000000000000000000001)
            mstore(0x5560, 0x0000000000000000000000000000000000000000000000000000000000000002)
            mstore(0x5580, mload(0x54e0))
            success := and(eq(staticcall(gas(), 0x7, 0x5540, 0x60, 0x5540, 0x40), 1), success)
            mstore(0x55a0, mload(0x5540))
            mstore(0x55c0, mload(0x5560))
            mstore(0x55e0, mload(0x740))
            mstore(0x5600, mload(0x760))
            success := and(eq(staticcall(gas(), 0x6, 0x55a0, 0x80, 0x55a0, 0x40), 1), success)
            mstore(0x5620, mload(0x920))
            mstore(0x5640, mload(0x940))
            mstore(0x5660, mload(0x4ac0))
            success := and(eq(staticcall(gas(), 0x7, 0x5620, 0x60, 0x5620, 0x40), 1), success)
            mstore(0x5680, mload(0x55a0))
            mstore(0x56a0, mload(0x55c0))
            mstore(0x56c0, mload(0x5620))
            mstore(0x56e0, mload(0x5640))
            success := and(eq(staticcall(gas(), 0x6, 0x5680, 0x80, 0x5680, 0x40), 1), success)
            mstore(0x5700, mload(0x960))
            mstore(0x5720, mload(0x980))
            mstore(0x5740, mload(0x4ae0))
            success := and(eq(staticcall(gas(), 0x7, 0x5700, 0x60, 0x5700, 0x40), 1), success)
            mstore(0x5760, mload(0x5680))
            mstore(0x5780, mload(0x56a0))
            mstore(0x57a0, mload(0x5700))
            mstore(0x57c0, mload(0x5720))
            success := and(eq(staticcall(gas(), 0x6, 0x5760, 0x80, 0x5760, 0x40), 1), success)
            mstore(0x57e0, mload(0x7e0))
            mstore(0x5800, mload(0x800))
            mstore(0x5820, mload(0x4be0))
            success := and(eq(staticcall(gas(), 0x7, 0x57e0, 0x60, 0x57e0, 0x40), 1), success)
            mstore(0x5840, mload(0x5760))
            mstore(0x5860, mload(0x5780))
            mstore(0x5880, mload(0x57e0))
            mstore(0x58a0, mload(0x5800))
            success := and(eq(staticcall(gas(), 0x6, 0x5840, 0x80, 0x5840, 0x40), 1), success)
            mstore(0x58c0, mload(0x820))
            mstore(0x58e0, mload(0x840))
            mstore(0x5900, mload(0x5340))
            success := and(eq(staticcall(gas(), 0x7, 0x58c0, 0x60, 0x58c0, 0x40), 1), success)
            mstore(0x5920, mload(0x5840))
            mstore(0x5940, mload(0x5860))
            mstore(0x5960, mload(0x58c0))
            mstore(0x5980, mload(0x58e0))
            success := and(eq(staticcall(gas(), 0x6, 0x5920, 0x80, 0x5920, 0x40), 1), success)
            mstore(0x59a0, 0x0c75190869878e76dc2e5d985c01a290e7ad0188a158d18b03cb14cd09ac2a9e)
            mstore(0x59c0, 0x04bec865431b156701d4877d90edb51933c79a2cd5c553b3dbb0bc3942a71e9d)
            mstore(0x59e0, mload(0x5360))
            success := and(eq(staticcall(gas(), 0x7, 0x59a0, 0x60, 0x59a0, 0x40), 1), success)
            mstore(0x5a00, mload(0x5920))
            mstore(0x5a20, mload(0x5940))
            mstore(0x5a40, mload(0x59a0))
            mstore(0x5a60, mload(0x59c0))
            success := and(eq(staticcall(gas(), 0x6, 0x5a00, 0x80, 0x5a00, 0x40), 1), success)
            mstore(0x5a80, 0x2eb40e2b0c13a6f4b989cffa9dbc452447bfd9f04a79f6379aefea8c9850a550)
            mstore(0x5aa0, 0x0efe5496541e2bd648d490f11ad542e1dec3127f818b8065843d0dd81358416c)
            mstore(0x5ac0, mload(0x5380))
            success := and(eq(staticcall(gas(), 0x7, 0x5a80, 0x60, 0x5a80, 0x40), 1), success)
            mstore(0x5ae0, mload(0x5a00))
            mstore(0x5b00, mload(0x5a20))
            mstore(0x5b20, mload(0x5a80))
            mstore(0x5b40, mload(0x5aa0))
            success := and(eq(staticcall(gas(), 0x6, 0x5ae0, 0x80, 0x5ae0, 0x40), 1), success)
            mstore(0x5b60, 0x223e520ce7ec36a2a31fa47de21b107545e18a61b9877cf72a518bfa2e6ba65c)
            mstore(0x5b80, 0x1950d1ba78f654305228b9eb8fa9cfda0dda697e1915bdaaa41755187f4f022b)
            mstore(0x5ba0, mload(0x53a0))
            success := and(eq(staticcall(gas(), 0x7, 0x5b60, 0x60, 0x5b60, 0x40), 1), success)
            mstore(0x5bc0, mload(0x5ae0))
            mstore(0x5be0, mload(0x5b00))
            mstore(0x5c00, mload(0x5b60))
            mstore(0x5c20, mload(0x5b80))
            success := and(eq(staticcall(gas(), 0x6, 0x5bc0, 0x80, 0x5bc0, 0x40), 1), success)
            mstore(0x5c40, 0x2b6da1c468131bc321794fcb730492c97479574da15b9c44d1ebe6edd0b23e93)
            mstore(0x5c60, 0x29570fa0b828b8587c7feaf56a7f1916c21da53f1c8b5ab6fae7baa3ce154f67)
            mstore(0x5c80, mload(0x53c0))
            success := and(eq(staticcall(gas(), 0x7, 0x5c40, 0x60, 0x5c40, 0x40), 1), success)
            mstore(0x5ca0, mload(0x5bc0))
            mstore(0x5cc0, mload(0x5be0))
            mstore(0x5ce0, mload(0x5c40))
            mstore(0x5d00, mload(0x5c60))
            success := and(eq(staticcall(gas(), 0x6, 0x5ca0, 0x80, 0x5ca0, 0x40), 1), success)
            mstore(0x5d20, 0x264790a3ffd6a11132518c3dfa0927d4c3d58c29a607f61bc29d51c0da93f6e8)
            mstore(0x5d40, 0x146849a602f55d840dde5d0e4a970b5b92f0eb33df26fe50fed301ce80476b0c)
            mstore(0x5d60, mload(0x53e0))
            success := and(eq(staticcall(gas(), 0x7, 0x5d20, 0x60, 0x5d20, 0x40), 1), success)
            mstore(0x5d80, mload(0x5ca0))
            mstore(0x5da0, mload(0x5cc0))
            mstore(0x5dc0, mload(0x5d20))
            mstore(0x5de0, mload(0x5d40))
            success := and(eq(staticcall(gas(), 0x6, 0x5d80, 0x80, 0x5d80, 0x40), 1), success)
            mstore(0x5e00, 0x14eb58c2e565eb8fb147bbef44e7262a3ed3c13302f21bfd426763338af36e5a)
            mstore(0x5e20, 0x0da5ed5250dda573e1beee0ab3b90bad9ef78d35505a4eb4dfd546596cf4717b)
            mstore(0x5e40, mload(0x5400))
            success := and(eq(staticcall(gas(), 0x7, 0x5e00, 0x60, 0x5e00, 0x40), 1), success)
            mstore(0x5e60, mload(0x5d80))
            mstore(0x5e80, mload(0x5da0))
            mstore(0x5ea0, mload(0x5e00))
            mstore(0x5ec0, mload(0x5e20))
            success := and(eq(staticcall(gas(), 0x6, 0x5e60, 0x80, 0x5e60, 0x40), 1), success)
            mstore(0x5ee0, 0x242f46256af4e18804e06758b830363ffe7099367cf48b039ffb6ea2a6fe8eda)
            mstore(0x5f00, 0x00f2eb8c1111ef1bb05d6635fb6f5abd7fa6f71f300e3a9572ffa354833db64a)
            mstore(0x5f20, mload(0x5420))
            success := and(eq(staticcall(gas(), 0x7, 0x5ee0, 0x60, 0x5ee0, 0x40), 1), success)
            mstore(0x5f40, mload(0x5e60))
            mstore(0x5f60, mload(0x5e80))
            mstore(0x5f80, mload(0x5ee0))
            mstore(0x5fa0, mload(0x5f00))
            success := and(eq(staticcall(gas(), 0x6, 0x5f40, 0x80, 0x5f40, 0x40), 1), success)
            mstore(0x5fc0, mload(0xa40))
            mstore(0x5fe0, mload(0xa60))
            mstore(0x6000, mload(0x5440))
            success := and(eq(staticcall(gas(), 0x7, 0x5fc0, 0x60, 0x5fc0, 0x40), 1), success)
            mstore(0x6020, mload(0x5f40))
            mstore(0x6040, mload(0x5f60))
            mstore(0x6060, mload(0x5fc0))
            mstore(0x6080, mload(0x5fe0))
            success := and(eq(staticcall(gas(), 0x6, 0x6020, 0x80, 0x6020, 0x40), 1), success)
            mstore(0x60a0, mload(0xa80))
            mstore(0x60c0, mload(0xaa0))
            mstore(0x60e0, mload(0x5460))
            success := and(eq(staticcall(gas(), 0x7, 0x60a0, 0x60, 0x60a0, 0x40), 1), success)
            mstore(0x6100, mload(0x6020))
            mstore(0x6120, mload(0x6040))
            mstore(0x6140, mload(0x60a0))
            mstore(0x6160, mload(0x60c0))
            success := and(eq(staticcall(gas(), 0x6, 0x6100, 0x80, 0x6100, 0x40), 1), success)
            mstore(0x6180, mload(0xac0))
            mstore(0x61a0, mload(0xae0))
            mstore(0x61c0, mload(0x5480))
            success := and(eq(staticcall(gas(), 0x7, 0x6180, 0x60, 0x6180, 0x40), 1), success)
            mstore(0x61e0, mload(0x6100))
            mstore(0x6200, mload(0x6120))
            mstore(0x6220, mload(0x6180))
            mstore(0x6240, mload(0x61a0))
            success := and(eq(staticcall(gas(), 0x6, 0x61e0, 0x80, 0x61e0, 0x40), 1), success)
            mstore(0x6260, mload(0xb00))
            mstore(0x6280, mload(0xb20))
            mstore(0x62a0, mload(0x54a0))
            success := and(eq(staticcall(gas(), 0x7, 0x6260, 0x60, 0x6260, 0x40), 1), success)
            mstore(0x62c0, mload(0x61e0))
            mstore(0x62e0, mload(0x6200))
            mstore(0x6300, mload(0x6260))
            mstore(0x6320, mload(0x6280))
            success := and(eq(staticcall(gas(), 0x6, 0x62c0, 0x80, 0x62c0, 0x40), 1), success)
            mstore(0x6340, mload(0x9a0))
            mstore(0x6360, mload(0x9c0))
            mstore(0x6380, mload(0x54c0))
            success := and(eq(staticcall(gas(), 0x7, 0x6340, 0x60, 0x6340, 0x40), 1), success)
            mstore(0x63a0, mload(0x62c0))
            mstore(0x63c0, mload(0x62e0))
            mstore(0x63e0, mload(0x6340))
            mstore(0x6400, mload(0x6360))
            success := and(eq(staticcall(gas(), 0x6, 0x63a0, 0x80, 0x63a0, 0x40), 1), success)
            mstore(0x6420, mload(0xec0))
            mstore(0x6440, mload(0xee0))
            mstore(0x6460, sub(f_q, mload(0x5500)))
            success := and(eq(staticcall(gas(), 0x7, 0x6420, 0x60, 0x6420, 0x40), 1), success)
            mstore(0x6480, mload(0x63a0))
            mstore(0x64a0, mload(0x63c0))
            mstore(0x64c0, mload(0x6420))
            mstore(0x64e0, mload(0x6440))
            success := and(eq(staticcall(gas(), 0x6, 0x6480, 0x80, 0x6480, 0x40), 1), success)
            mstore(0x6500, mload(0xf60))
            mstore(0x6520, mload(0xf80))
            mstore(0x6540, mload(0x5520))
            success := and(eq(staticcall(gas(), 0x7, 0x6500, 0x60, 0x6500, 0x40), 1), success)
            mstore(0x6560, mload(0x6480))
            mstore(0x6580, mload(0x64a0))
            mstore(0x65a0, mload(0x6500))
            mstore(0x65c0, mload(0x6520))
            success := and(eq(staticcall(gas(), 0x6, 0x6560, 0x80, 0x6560, 0x40), 1), success)
            mstore(0x65e0, mload(0x6560))
            mstore(0x6600, mload(0x6580))
            mstore(0x6620, mload(0xf60))
            mstore(0x6640, mload(0xf80))
            mstore(0x6660, mload(0xfa0))
            mstore(0x6680, mload(0xfc0))
            mstore(0x66a0, mload(0xfe0))
            mstore(0x66c0, mload(0x1000))
            mstore(0x66e0, keccak256(0x65e0, 256))
            mstore(26368, mod(mload(26336), f_q))
            mstore(0x6720, mulmod(mload(0x6700), mload(0x6700), f_q))
            mstore(0x6740, mulmod(1, mload(0x6700), f_q))
            mstore(0x6760, mload(0x6660))
            mstore(0x6780, mload(0x6680))
            mstore(0x67a0, mload(0x6740))
            success := and(eq(staticcall(gas(), 0x7, 0x6760, 0x60, 0x6760, 0x40), 1), success)
            mstore(0x67c0, mload(0x65e0))
            mstore(0x67e0, mload(0x6600))
            mstore(0x6800, mload(0x6760))
            mstore(0x6820, mload(0x6780))
            success := and(eq(staticcall(gas(), 0x6, 0x67c0, 0x80, 0x67c0, 0x40), 1), success)
            mstore(0x6840, mload(0x66a0))
            mstore(0x6860, mload(0x66c0))
            mstore(0x6880, mload(0x6740))
            success := and(eq(staticcall(gas(), 0x7, 0x6840, 0x60, 0x6840, 0x40), 1), success)
            mstore(0x68a0, mload(0x6620))
            mstore(0x68c0, mload(0x6640))
            mstore(0x68e0, mload(0x6840))
            mstore(0x6900, mload(0x6860))
            success := and(eq(staticcall(gas(), 0x6, 0x68a0, 0x80, 0x68a0, 0x40), 1), success)
            mstore(0x6920, mload(0x67c0))
            mstore(0x6940, mload(0x67e0))
            mstore(0x6960, 0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2)
            mstore(0x6980, 0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed)
            mstore(0x69a0, 0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b)
            mstore(0x69c0, 0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa)
            mstore(0x69e0, mload(0x68a0))
            mstore(0x6a00, mload(0x68c0))
            mstore(0x6a20, 0x172aa93c41f16e1e04d62ac976a5d945f4be0acab990c6dc19ac4a7cf68bf77b)
            mstore(0x6a40, 0x2ae0c8c3a090f7200ff398ee9845bbae8f8c1445ae7b632212775f60a0e21600)
            mstore(0x6a60, 0x190fa476a5b352809ed41d7a0d7fe12b8f685e3c12a6d83855dba27aaf469643)
            mstore(0x6a80, 0x1c0a500618907df9e4273d5181e31088deb1f05132de037cbfe73888f97f77c9)
            success := and(eq(staticcall(gas(), 0x8, 0x6920, 0x180, 0x6920, 0x20), 1), success)
            success := and(eq(mload(0x6920), 1), success)

            // Revert if anything fails
            if iszero(success) { revert(0, 0) }

            // Return empty bytes on success
            return(0, 0)
        }
    }
}
