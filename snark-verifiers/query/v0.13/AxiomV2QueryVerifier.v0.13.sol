// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract AxiomV2QueryVerifier {
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
            mstore(0x80, 15186165512185359347397944531838604952299016691786397857821503921188369501699)

            {
                let x := calldataload(0x2e0)
                mstore(0x380, x)
                let y := calldataload(0x300)
                mstore(0x3a0, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x3c0, keccak256(0x80, 832))
            {
                let hash := mload(0x3c0)
                mstore(0x3e0, mod(hash, f_q))
                mstore(0x400, hash)
            }

            {
                let x := calldataload(0x320)
                mstore(0x420, x)
                let y := calldataload(0x340)
                mstore(0x440, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x360)
                mstore(0x460, x)
                let y := calldataload(0x380)
                mstore(0x480, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x4a0, keccak256(0x400, 160))
            {
                let hash := mload(0x4a0)
                mstore(0x4c0, mod(hash, f_q))
                mstore(0x4e0, hash)
            }
            mstore8(1280, 1)
            mstore(0x500, keccak256(0x4e0, 33))
            {
                let hash := mload(0x500)
                mstore(0x520, mod(hash, f_q))
                mstore(0x540, hash)
            }

            {
                let x := calldataload(0x3a0)
                mstore(0x560, x)
                let y := calldataload(0x3c0)
                mstore(0x580, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x3e0)
                mstore(0x5a0, x)
                let y := calldataload(0x400)
                mstore(0x5c0, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x420)
                mstore(0x5e0, x)
                let y := calldataload(0x440)
                mstore(0x600, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x620, keccak256(0x540, 224))
            {
                let hash := mload(0x620)
                mstore(0x640, mod(hash, f_q))
                mstore(0x660, hash)
            }

            {
                let x := calldataload(0x460)
                mstore(0x680, x)
                let y := calldataload(0x480)
                mstore(0x6a0, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x4a0)
                mstore(0x6c0, x)
                let y := calldataload(0x4c0)
                mstore(0x6e0, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x4e0)
                mstore(0x700, x)
                let y := calldataload(0x500)
                mstore(0x720, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x520)
                mstore(0x740, x)
                let y := calldataload(0x540)
                mstore(0x760, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x780, keccak256(0x660, 288))
            {
                let hash := mload(0x780)
                mstore(0x7a0, mod(hash, f_q))
                mstore(0x7c0, hash)
            }
            mstore(0x7e0, mod(calldataload(0x560), f_q))
            mstore(0x800, mod(calldataload(0x580), f_q))
            mstore(0x820, mod(calldataload(0x5a0), f_q))
            mstore(0x840, mod(calldataload(0x5c0), f_q))
            mstore(0x860, mod(calldataload(0x5e0), f_q))
            mstore(0x880, mod(calldataload(0x600), f_q))
            mstore(0x8a0, mod(calldataload(0x620), f_q))
            mstore(0x8c0, mod(calldataload(0x640), f_q))
            mstore(0x8e0, mod(calldataload(0x660), f_q))
            mstore(0x900, mod(calldataload(0x680), f_q))
            mstore(0x920, mod(calldataload(0x6a0), f_q))
            mstore(0x940, mod(calldataload(0x6c0), f_q))
            mstore(0x960, mod(calldataload(0x6e0), f_q))
            mstore(0x980, mod(calldataload(0x700), f_q))
            mstore(0x9a0, mod(calldataload(0x720), f_q))
            mstore(0x9c0, mod(calldataload(0x740), f_q))
            mstore(0x9e0, mod(calldataload(0x760), f_q))
            mstore(0xa00, mod(calldataload(0x780), f_q))
            mstore(0xa20, mod(calldataload(0x7a0), f_q))
            mstore(0xa40, keccak256(0x7c0, 640))
            {
                let hash := mload(0xa40)
                mstore(0xa60, mod(hash, f_q))
                mstore(0xa80, hash)
            }
            mstore8(2720, 1)
            mstore(0xaa0, keccak256(0xa80, 33))
            {
                let hash := mload(0xaa0)
                mstore(0xac0, mod(hash, f_q))
                mstore(0xae0, hash)
            }

            {
                let x := calldataload(0x7c0)
                mstore(0xb00, x)
                let y := calldataload(0x7e0)
                mstore(0xb20, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0xb40, keccak256(0xae0, 96))
            {
                let hash := mload(0xb40)
                mstore(0xb60, mod(hash, f_q))
                mstore(0xb80, hash)
            }

            {
                let x := calldataload(0x800)
                mstore(0xba0, x)
                let y := calldataload(0x820)
                mstore(0xbc0, y)
                success := and(validate_ec_point(x, y), success)
            }
            {
                let x := mload(0xa0)
                x := add(x, shl(88, mload(0xc0)))
                x := add(x, shl(176, mload(0xe0)))
                mstore(3040, x)
                let y := mload(0x100)
                y := add(y, shl(88, mload(0x120)))
                y := add(y, shl(176, mload(0x140)))
                mstore(3072, y)

                success := and(validate_ec_point(x, y), success)
            }
            {
                let x := mload(0x160)
                x := add(x, shl(88, mload(0x180)))
                x := add(x, shl(176, mload(0x1a0)))
                mstore(3104, x)
                let y := mload(0x1c0)
                y := add(y, shl(88, mload(0x1e0)))
                y := add(y, shl(176, mload(0x200)))
                mstore(3136, y)

                success := and(validate_ec_point(x, y), success)
            }
            mstore(0xc60, mulmod(mload(0x7a0), mload(0x7a0), f_q))
            mstore(0xc80, mulmod(mload(0xc60), mload(0xc60), f_q))
            mstore(0xca0, mulmod(mload(0xc80), mload(0xc80), f_q))
            mstore(0xcc0, mulmod(mload(0xca0), mload(0xca0), f_q))
            mstore(0xce0, mulmod(mload(0xcc0), mload(0xcc0), f_q))
            mstore(0xd00, mulmod(mload(0xce0), mload(0xce0), f_q))
            mstore(0xd20, mulmod(mload(0xd00), mload(0xd00), f_q))
            mstore(0xd40, mulmod(mload(0xd20), mload(0xd20), f_q))
            mstore(0xd60, mulmod(mload(0xd40), mload(0xd40), f_q))
            mstore(0xd80, mulmod(mload(0xd60), mload(0xd60), f_q))
            mstore(0xda0, mulmod(mload(0xd80), mload(0xd80), f_q))
            mstore(0xdc0, mulmod(mload(0xda0), mload(0xda0), f_q))
            mstore(0xde0, mulmod(mload(0xdc0), mload(0xdc0), f_q))
            mstore(0xe00, mulmod(mload(0xde0), mload(0xde0), f_q))
            mstore(0xe20, mulmod(mload(0xe00), mload(0xe00), f_q))
            mstore(0xe40, mulmod(mload(0xe20), mload(0xe20), f_q))
            mstore(0xe60, mulmod(mload(0xe40), mload(0xe40), f_q))
            mstore(0xe80, mulmod(mload(0xe60), mload(0xe60), f_q))
            mstore(0xea0, mulmod(mload(0xe80), mload(0xe80), f_q))
            mstore(0xec0, mulmod(mload(0xea0), mload(0xea0), f_q))
            mstore(0xee0, mulmod(mload(0xec0), mload(0xec0), f_q))
            mstore(0xf00, mulmod(mload(0xee0), mload(0xee0), f_q))
            mstore(0xf20, mulmod(mload(0xf00), mload(0xf00), f_q))
            mstore(
                0xf40,
                addmod(mload(0xf20), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q)
            )
            mstore(
                0xf60,
                mulmod(mload(0xf40), 21888240262557392955334514970720457388010314637169927192662615958087340972065, f_q)
            )
            mstore(
                0xf80,
                mulmod(mload(0xf60), 4506835738822104338668100540817374747935106310012997856968187171738630203507, f_q)
            )
            mstore(
                0xfa0,
                addmod(mload(0x7a0), 17381407133017170883578305204439900340613258090403036486730017014837178292110, f_q)
            )
            mstore(
                0xfc0,
                mulmod(mload(0xf60), 21710372849001950800533397158415938114909991150039389063546734567764856596059, f_q)
            )
            mstore(
                0xfe0,
                addmod(mload(0x7a0), 177870022837324421713008586841336973638373250376645280151469618810951899558, f_q)
            )
            mstore(
                0x1000,
                mulmod(mload(0xf60), 1887003188133998471169152042388914354640772748308168868301418279904560637395, f_q)
            )
            mstore(
                0x1020,
                addmod(mload(0x7a0), 20001239683705276751077253702868360733907591652107865475396785906671247858222, f_q)
            )
            mstore(
                0x1040,
                mulmod(mload(0xf60), 2785514556381676080176937710880804108647911392478702105860685610379369825016, f_q)
            )
            mstore(
                0x1060,
                addmod(mload(0x7a0), 19102728315457599142069468034376470979900453007937332237837518576196438670601, f_q)
            )
            mstore(
                0x1080,
                mulmod(mload(0xf60), 14655294445420895451632927078981340937842238432098198055057679026789553137428, f_q)
            )
            mstore(
                0x10a0,
                addmod(mload(0x7a0), 7232948426418379770613478666275934150706125968317836288640525159786255358189, f_q)
            )
            mstore(
                0x10c0,
                mulmod(mload(0xf60), 8734126352828345679573237859165904705806588461301144420590422589042130041188, f_q)
            )
            mstore(
                0x10e0,
                addmod(mload(0x7a0), 13154116519010929542673167886091370382741775939114889923107781597533678454429, f_q)
            )
            mstore(
                0x1100,
                mulmod(mload(0xf60), 9741553891420464328295280489650144566903017206473301385034033384879943874347, f_q)
            )
            mstore(
                0x1120,
                addmod(mload(0x7a0), 12146688980418810893951125255607130521645347193942732958664170801695864621270, f_q)
            )
            mstore(0x1140, mulmod(mload(0xf60), 1, f_q))
            mstore(
                0x1160,
                addmod(mload(0x7a0), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q)
            )
            mstore(
                0x1180,
                mulmod(mload(0xf60), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            mstore(
                0x11a0,
                addmod(mload(0x7a0), 13513867906530865119835332133273263211836799082674232843258448413103731898270, f_q)
            )
            mstore(
                0x11c0,
                mulmod(mload(0xf60), 11211301017135681023579411905410872569206244553457844956874280139879520583390, f_q)
            )
            mstore(
                0x11e0,
                addmod(mload(0x7a0), 10676941854703594198666993839846402519342119846958189386823924046696287912227, f_q)
            )
            mstore(
                0x1200,
                mulmod(mload(0xf60), 3615478808282855240548287271348143516886772452944084747768312988864436725401, f_q)
            )
            mstore(
                0x1220,
                addmod(mload(0x7a0), 18272764063556419981698118473909131571661591947471949595929891197711371770216, f_q)
            )
            mstore(
                0x1240,
                mulmod(mload(0xf60), 1426404432721484388505361748317961535523355871255605456897797744433766488507, f_q)
            )
            mstore(
                0x1260,
                addmod(mload(0x7a0), 20461838439117790833741043996939313553025008529160428886800406442142042007110, f_q)
            )
            mstore(
                0x1280,
                mulmod(mload(0xf60), 216092043779272773661818549620449970334216366264741118684015851799902419467, f_q)
            )
            mstore(
                0x12a0,
                addmod(mload(0x7a0), 21672150828060002448584587195636825118214148034151293225014188334775906076150, f_q)
            )
            mstore(
                0x12c0,
                mulmod(mload(0xf60), 12619617507853212586156872920672483948819476989779550311307282715684870266992, f_q)
            )
            mstore(
                0x12e0,
                addmod(mload(0x7a0), 9268625363986062636089532824584791139728887410636484032390921470890938228625, f_q)
            )
            mstore(
                0x1300,
                mulmod(mload(0xf60), 18610195890048912503953886742825279624920778288956610528523679659246523534888, f_q)
            )
            mstore(
                0x1320,
                addmod(mload(0x7a0), 3278046981790362718292519002431995463627586111459423815174524527329284960729, f_q)
            )
            mstore(
                0x1340,
                mulmod(mload(0xf60), 19032961837237948602743626455740240236231119053033140765040043513661803148152, f_q)
            )
            mstore(
                0x1360,
                addmod(mload(0x7a0), 2855281034601326619502779289517034852317245347382893578658160672914005347465, f_q)
            )
            mstore(
                0x1380,
                mulmod(mload(0xf60), 14875928112196239563830800280253496262679717528621719058794366823499719730250, f_q)
            )
            mstore(
                0x13a0,
                addmod(mload(0x7a0), 7012314759643035658415605465003778825868646871794315284903837363076088765367, f_q)
            )
            mstore(
                0x13c0,
                mulmod(mload(0xf60), 915149353520972163646494413843788069594022902357002628455555785223409501882, f_q)
            )
            mstore(
                0x13e0,
                addmod(mload(0x7a0), 20973093518318303058599911331413487018954341498059031715242648401352398993735, f_q)
            )
            mstore(
                0x1400,
                mulmod(mload(0xf60), 5522161504810533295870699551020523636289972223872138525048055197429246400245, f_q)
            )
            mstore(
                0x1420,
                addmod(mload(0x7a0), 16366081367028741926375706194236751452258392176543895818650148989146562095372, f_q)
            )
            mstore(
                0x1440,
                mulmod(mload(0xf60), 3766081621734395783232337525162072736827576297943013392955872170138036189193, f_q)
            )
            mstore(
                0x1460,
                addmod(mload(0x7a0), 18122161250104879439014068220095202351720788102473020950742332016437772306424, f_q)
            )
            mstore(
                0x1480,
                mulmod(mload(0xf60), 9100833993744738801214480881117348002768153232283708533639316963648253510584, f_q)
            )
            mstore(
                0x14a0,
                addmod(mload(0x7a0), 12787408878094536421031924864139927085780211168132325810058887222927554985033, f_q)
            )
            mstore(
                0x14c0,
                mulmod(mload(0xf60), 4245441013247250116003069945606352967193023389718465410501109428393342802981, f_q)
            )
            mstore(
                0x14e0,
                addmod(mload(0x7a0), 17642801858592025106243335799650922121355341010697568933197094758182465692636, f_q)
            )
            mstore(
                0x1500,
                mulmod(mload(0xf60), 6132660129994545119218258312491950835441607143741804980633129304664017206141, f_q)
            )
            mstore(
                0x1520,
                addmod(mload(0x7a0), 15755582741844730103028147432765324253106757256674229363065074881911791289476, f_q)
            )
            mstore(
                0x1540,
                mulmod(mload(0xf60), 5854133144571823792863860130267644613802765696134002830362054821530146160770, f_q)
            )
            mstore(
                0x1560,
                addmod(mload(0x7a0), 16034109727267451429382545614989630474745598704282031513336149365045662334847, f_q)
            )
            mstore(
                0x1580,
                mulmod(mload(0xf60), 515148244606945972463850631189471072103916690263705052318085725998468254533, f_q)
            )
            mstore(
                0x15a0,
                addmod(mload(0x7a0), 21373094627232329249782555114067804016444447710152329291380118460577340241084, f_q)
            )
            mstore(
                0x15c0,
                mulmod(mload(0xf60), 5980488956150442207659150513163747165544364597008566989111579977672498964212, f_q)
            )
            mstore(
                0x15e0,
                addmod(mload(0x7a0), 15907753915688833014587255232093527923003999803407467354586624208903309531405, f_q)
            )
            mstore(
                0x1600,
                mulmod(mload(0xf60), 5223738580615264174925218065001555728265216895679471490312087802465486318994, f_q)
            )
            mstore(
                0x1620,
                addmod(mload(0x7a0), 16664504291224011047321187680255719360283147504736562853386116384110322176623, f_q)
            )
            mstore(
                0x1640,
                mulmod(mload(0xf60), 14557038802599140430182096396825290815503940951075961210638273254419942783582, f_q)
            )
            mstore(
                0x1660,
                addmod(mload(0x7a0), 7331204069240134792064309348431984273044423449340073133059930932155865712035, f_q)
            )
            mstore(
                0x1680,
                mulmod(mload(0xf60), 16976236069879939850923145256911338076234942200101755618884183331004076579046, f_q)
            )
            mstore(
                0x16a0,
                addmod(mload(0x7a0), 4912006801959335371323260488345937012313422200314278724814020855571731916571, f_q)
            )
            mstore(
                0x16c0,
                mulmod(mload(0xf60), 13553911191894110065493137367144919847521088405945523452288398666974237857208, f_q)
            )
            mstore(
                0x16e0,
                addmod(mload(0x7a0), 8334331679945165156753268378112355241027275994470510891409805519601570638409, f_q)
            )
            {
                let prod := mload(0xfa0)

                prod := mulmod(mload(0xfe0), prod, f_q)
                mstore(0x1700, prod)

                prod := mulmod(mload(0x1020), prod, f_q)
                mstore(0x1720, prod)

                prod := mulmod(mload(0x1060), prod, f_q)
                mstore(0x1740, prod)

                prod := mulmod(mload(0x10a0), prod, f_q)
                mstore(0x1760, prod)

                prod := mulmod(mload(0x10e0), prod, f_q)
                mstore(0x1780, prod)

                prod := mulmod(mload(0x1120), prod, f_q)
                mstore(0x17a0, prod)

                prod := mulmod(mload(0x1160), prod, f_q)
                mstore(0x17c0, prod)

                prod := mulmod(mload(0x11a0), prod, f_q)
                mstore(0x17e0, prod)

                prod := mulmod(mload(0x11e0), prod, f_q)
                mstore(0x1800, prod)

                prod := mulmod(mload(0x1220), prod, f_q)
                mstore(0x1820, prod)

                prod := mulmod(mload(0x1260), prod, f_q)
                mstore(0x1840, prod)

                prod := mulmod(mload(0x12a0), prod, f_q)
                mstore(0x1860, prod)

                prod := mulmod(mload(0x12e0), prod, f_q)
                mstore(0x1880, prod)

                prod := mulmod(mload(0x1320), prod, f_q)
                mstore(0x18a0, prod)

                prod := mulmod(mload(0x1360), prod, f_q)
                mstore(0x18c0, prod)

                prod := mulmod(mload(0x13a0), prod, f_q)
                mstore(0x18e0, prod)

                prod := mulmod(mload(0x13e0), prod, f_q)
                mstore(0x1900, prod)

                prod := mulmod(mload(0x1420), prod, f_q)
                mstore(0x1920, prod)

                prod := mulmod(mload(0x1460), prod, f_q)
                mstore(0x1940, prod)

                prod := mulmod(mload(0x14a0), prod, f_q)
                mstore(0x1960, prod)

                prod := mulmod(mload(0x14e0), prod, f_q)
                mstore(0x1980, prod)

                prod := mulmod(mload(0x1520), prod, f_q)
                mstore(0x19a0, prod)

                prod := mulmod(mload(0x1560), prod, f_q)
                mstore(0x19c0, prod)

                prod := mulmod(mload(0x15a0), prod, f_q)
                mstore(0x19e0, prod)

                prod := mulmod(mload(0x15e0), prod, f_q)
                mstore(0x1a00, prod)

                prod := mulmod(mload(0x1620), prod, f_q)
                mstore(0x1a20, prod)

                prod := mulmod(mload(0x1660), prod, f_q)
                mstore(0x1a40, prod)

                prod := mulmod(mload(0x16a0), prod, f_q)
                mstore(0x1a60, prod)

                prod := mulmod(mload(0x16e0), prod, f_q)
                mstore(0x1a80, prod)

                prod := mulmod(mload(0xf40), prod, f_q)
                mstore(0x1aa0, prod)
            }
            mstore(0x1ae0, 32)
            mstore(0x1b00, 32)
            mstore(0x1b20, 32)
            mstore(0x1b40, mload(0x1aa0))
            mstore(0x1b60, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
            mstore(0x1b80, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
            success := and(eq(staticcall(gas(), 0x5, 0x1ae0, 0xc0, 0x1ac0, 0x20), 1), success)
            {
                let inv := mload(0x1ac0)
                let v

                v := mload(0xf40)
                mstore(3904, mulmod(mload(0x1a80), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x16e0)
                mstore(5856, mulmod(mload(0x1a60), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x16a0)
                mstore(5792, mulmod(mload(0x1a40), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1660)
                mstore(5728, mulmod(mload(0x1a20), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1620)
                mstore(5664, mulmod(mload(0x1a00), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x15e0)
                mstore(5600, mulmod(mload(0x19e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x15a0)
                mstore(5536, mulmod(mload(0x19c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1560)
                mstore(5472, mulmod(mload(0x19a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1520)
                mstore(5408, mulmod(mload(0x1980), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x14e0)
                mstore(5344, mulmod(mload(0x1960), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x14a0)
                mstore(5280, mulmod(mload(0x1940), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1460)
                mstore(5216, mulmod(mload(0x1920), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1420)
                mstore(5152, mulmod(mload(0x1900), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x13e0)
                mstore(5088, mulmod(mload(0x18e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x13a0)
                mstore(5024, mulmod(mload(0x18c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1360)
                mstore(4960, mulmod(mload(0x18a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1320)
                mstore(4896, mulmod(mload(0x1880), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x12e0)
                mstore(4832, mulmod(mload(0x1860), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x12a0)
                mstore(4768, mulmod(mload(0x1840), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1260)
                mstore(4704, mulmod(mload(0x1820), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1220)
                mstore(4640, mulmod(mload(0x1800), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x11e0)
                mstore(4576, mulmod(mload(0x17e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x11a0)
                mstore(4512, mulmod(mload(0x17c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1160)
                mstore(4448, mulmod(mload(0x17a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1120)
                mstore(4384, mulmod(mload(0x1780), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x10e0)
                mstore(4320, mulmod(mload(0x1760), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x10a0)
                mstore(4256, mulmod(mload(0x1740), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1060)
                mstore(4192, mulmod(mload(0x1720), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1020)
                mstore(4128, mulmod(mload(0x1700), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0xfe0)
                mstore(4064, mulmod(mload(0xfa0), inv, f_q))
                inv := mulmod(v, inv, f_q)
                mstore(0xfa0, inv)
            }
            mstore(0x1ba0, mulmod(mload(0xf80), mload(0xfa0), f_q))
            mstore(0x1bc0, mulmod(mload(0xfc0), mload(0xfe0), f_q))
            mstore(0x1be0, mulmod(mload(0x1000), mload(0x1020), f_q))
            mstore(0x1c00, mulmod(mload(0x1040), mload(0x1060), f_q))
            mstore(0x1c20, mulmod(mload(0x1080), mload(0x10a0), f_q))
            mstore(0x1c40, mulmod(mload(0x10c0), mload(0x10e0), f_q))
            mstore(0x1c60, mulmod(mload(0x1100), mload(0x1120), f_q))
            mstore(0x1c80, mulmod(mload(0x1140), mload(0x1160), f_q))
            mstore(0x1ca0, mulmod(mload(0x1180), mload(0x11a0), f_q))
            mstore(0x1cc0, mulmod(mload(0x11c0), mload(0x11e0), f_q))
            mstore(0x1ce0, mulmod(mload(0x1200), mload(0x1220), f_q))
            mstore(0x1d00, mulmod(mload(0x1240), mload(0x1260), f_q))
            mstore(0x1d20, mulmod(mload(0x1280), mload(0x12a0), f_q))
            mstore(0x1d40, mulmod(mload(0x12c0), mload(0x12e0), f_q))
            mstore(0x1d60, mulmod(mload(0x1300), mload(0x1320), f_q))
            mstore(0x1d80, mulmod(mload(0x1340), mload(0x1360), f_q))
            mstore(0x1da0, mulmod(mload(0x1380), mload(0x13a0), f_q))
            mstore(0x1dc0, mulmod(mload(0x13c0), mload(0x13e0), f_q))
            mstore(0x1de0, mulmod(mload(0x1400), mload(0x1420), f_q))
            mstore(0x1e00, mulmod(mload(0x1440), mload(0x1460), f_q))
            mstore(0x1e20, mulmod(mload(0x1480), mload(0x14a0), f_q))
            mstore(0x1e40, mulmod(mload(0x14c0), mload(0x14e0), f_q))
            mstore(0x1e60, mulmod(mload(0x1500), mload(0x1520), f_q))
            mstore(0x1e80, mulmod(mload(0x1540), mload(0x1560), f_q))
            mstore(0x1ea0, mulmod(mload(0x1580), mload(0x15a0), f_q))
            mstore(0x1ec0, mulmod(mload(0x15c0), mload(0x15e0), f_q))
            mstore(0x1ee0, mulmod(mload(0x1600), mload(0x1620), f_q))
            mstore(0x1f00, mulmod(mload(0x1640), mload(0x1660), f_q))
            mstore(0x1f20, mulmod(mload(0x1680), mload(0x16a0), f_q))
            mstore(0x1f40, mulmod(mload(0x16c0), mload(0x16e0), f_q))
            {
                let result := mulmod(mload(0x1c80), mload(0xa0), f_q)
                result := addmod(mulmod(mload(0x1ca0), mload(0xc0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1cc0), mload(0xe0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1ce0), mload(0x100), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1d00), mload(0x120), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1d20), mload(0x140), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1d40), mload(0x160), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1d60), mload(0x180), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1d80), mload(0x1a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1da0), mload(0x1c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1dc0), mload(0x1e0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1de0), mload(0x200), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1e00), mload(0x220), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1e20), mload(0x240), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1e40), mload(0x260), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1e60), mload(0x280), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1e80), mload(0x2a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1ea0), mload(0x2c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1ec0), mload(0x2e0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1ee0), mload(0x300), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1f00), mload(0x320), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1f20), mload(0x340), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1f40), mload(0x360), f_q), result, f_q)
                mstore(8032, result)
            }
            mstore(0x1f80, mulmod(mload(0x820), mload(0x800), f_q))
            mstore(0x1fa0, addmod(mload(0x7e0), mload(0x1f80), f_q))
            mstore(0x1fc0, addmod(mload(0x1fa0), sub(f_q, mload(0x840)), f_q))
            mstore(0x1fe0, mulmod(mload(0x1fc0), mload(0x8a0), f_q))
            mstore(0x2000, mulmod(mload(0x640), mload(0x1fe0), f_q))
            mstore(0x2020, addmod(1, sub(f_q, mload(0x960)), f_q))
            mstore(0x2040, mulmod(mload(0x2020), mload(0x1c80), f_q))
            mstore(0x2060, addmod(mload(0x2000), mload(0x2040), f_q))
            mstore(0x2080, mulmod(mload(0x640), mload(0x2060), f_q))
            mstore(0x20a0, mulmod(mload(0x960), mload(0x960), f_q))
            mstore(0x20c0, addmod(mload(0x20a0), sub(f_q, mload(0x960)), f_q))
            mstore(0x20e0, mulmod(mload(0x20c0), mload(0x1ba0), f_q))
            mstore(0x2100, addmod(mload(0x2080), mload(0x20e0), f_q))
            mstore(0x2120, mulmod(mload(0x640), mload(0x2100), f_q))
            mstore(0x2140, addmod(1, sub(f_q, mload(0x1ba0)), f_q))
            mstore(0x2160, addmod(mload(0x1bc0), mload(0x1be0), f_q))
            mstore(0x2180, addmod(mload(0x2160), mload(0x1c00), f_q))
            mstore(0x21a0, addmod(mload(0x2180), mload(0x1c20), f_q))
            mstore(0x21c0, addmod(mload(0x21a0), mload(0x1c40), f_q))
            mstore(0x21e0, addmod(mload(0x21c0), mload(0x1c60), f_q))
            mstore(0x2200, addmod(mload(0x2140), sub(f_q, mload(0x21e0)), f_q))
            mstore(0x2220, mulmod(mload(0x900), mload(0x4c0), f_q))
            mstore(0x2240, addmod(mload(0x860), mload(0x2220), f_q))
            mstore(0x2260, addmod(mload(0x2240), mload(0x520), f_q))
            mstore(0x2280, mulmod(mload(0x920), mload(0x4c0), f_q))
            mstore(0x22a0, addmod(mload(0x7e0), mload(0x2280), f_q))
            mstore(0x22c0, addmod(mload(0x22a0), mload(0x520), f_q))
            mstore(0x22e0, mulmod(mload(0x22c0), mload(0x2260), f_q))
            mstore(0x2300, mulmod(mload(0x940), mload(0x4c0), f_q))
            mstore(0x2320, addmod(mload(0x1f60), mload(0x2300), f_q))
            mstore(0x2340, addmod(mload(0x2320), mload(0x520), f_q))
            mstore(0x2360, mulmod(mload(0x2340), mload(0x22e0), f_q))
            mstore(0x2380, mulmod(mload(0x2360), mload(0x980), f_q))
            mstore(0x23a0, mulmod(1, mload(0x4c0), f_q))
            mstore(0x23c0, mulmod(mload(0x7a0), mload(0x23a0), f_q))
            mstore(0x23e0, addmod(mload(0x860), mload(0x23c0), f_q))
            mstore(0x2400, addmod(mload(0x23e0), mload(0x520), f_q))
            mstore(
                0x2420,
                mulmod(4131629893567559867359510883348571134090853742863529169391034518566172092834, mload(0x4c0), f_q)
            )
            mstore(0x2440, mulmod(mload(0x7a0), mload(0x2420), f_q))
            mstore(0x2460, addmod(mload(0x7e0), mload(0x2440), f_q))
            mstore(0x2480, addmod(mload(0x2460), mload(0x520), f_q))
            mstore(0x24a0, mulmod(mload(0x2480), mload(0x2400), f_q))
            mstore(
                0x24c0,
                mulmod(8910878055287538404433155982483128285667088683464058436815641868457422632747, mload(0x4c0), f_q)
            )
            mstore(0x24e0, mulmod(mload(0x7a0), mload(0x24c0), f_q))
            mstore(0x2500, addmod(mload(0x1f60), mload(0x24e0), f_q))
            mstore(0x2520, addmod(mload(0x2500), mload(0x520), f_q))
            mstore(0x2540, mulmod(mload(0x2520), mload(0x24a0), f_q))
            mstore(0x2560, mulmod(mload(0x2540), mload(0x960), f_q))
            mstore(0x2580, addmod(mload(0x2380), sub(f_q, mload(0x2560)), f_q))
            mstore(0x25a0, mulmod(mload(0x2580), mload(0x2200), f_q))
            mstore(0x25c0, addmod(mload(0x2120), mload(0x25a0), f_q))
            mstore(0x25e0, mulmod(mload(0x640), mload(0x25c0), f_q))
            mstore(0x2600, addmod(1, sub(f_q, mload(0x9a0)), f_q))
            mstore(0x2620, mulmod(mload(0x2600), mload(0x1c80), f_q))
            mstore(0x2640, addmod(mload(0x25e0), mload(0x2620), f_q))
            mstore(0x2660, mulmod(mload(0x640), mload(0x2640), f_q))
            mstore(0x2680, mulmod(mload(0x9a0), mload(0x9a0), f_q))
            mstore(0x26a0, addmod(mload(0x2680), sub(f_q, mload(0x9a0)), f_q))
            mstore(0x26c0, mulmod(mload(0x26a0), mload(0x1ba0), f_q))
            mstore(0x26e0, addmod(mload(0x2660), mload(0x26c0), f_q))
            mstore(0x2700, mulmod(mload(0x640), mload(0x26e0), f_q))
            mstore(0x2720, addmod(mload(0x9e0), mload(0x4c0), f_q))
            mstore(0x2740, mulmod(mload(0x2720), mload(0x9c0), f_q))
            mstore(0x2760, addmod(mload(0xa20), mload(0x520), f_q))
            mstore(0x2780, mulmod(mload(0x2760), mload(0x2740), f_q))
            mstore(0x27a0, mulmod(mload(0x7e0), mload(0x8c0), f_q))
            mstore(0x27c0, addmod(mload(0x27a0), mload(0x4c0), f_q))
            mstore(0x27e0, mulmod(mload(0x27c0), mload(0x9a0), f_q))
            mstore(0x2800, addmod(mload(0x880), mload(0x520), f_q))
            mstore(0x2820, mulmod(mload(0x2800), mload(0x27e0), f_q))
            mstore(0x2840, addmod(mload(0x2780), sub(f_q, mload(0x2820)), f_q))
            mstore(0x2860, mulmod(mload(0x2840), mload(0x2200), f_q))
            mstore(0x2880, addmod(mload(0x2700), mload(0x2860), f_q))
            mstore(0x28a0, mulmod(mload(0x640), mload(0x2880), f_q))
            mstore(0x28c0, addmod(mload(0x9e0), sub(f_q, mload(0xa20)), f_q))
            mstore(0x28e0, mulmod(mload(0x28c0), mload(0x1c80), f_q))
            mstore(0x2900, addmod(mload(0x28a0), mload(0x28e0), f_q))
            mstore(0x2920, mulmod(mload(0x640), mload(0x2900), f_q))
            mstore(0x2940, mulmod(mload(0x28c0), mload(0x2200), f_q))
            mstore(0x2960, addmod(mload(0x9e0), sub(f_q, mload(0xa00)), f_q))
            mstore(0x2980, mulmod(mload(0x2960), mload(0x2940), f_q))
            mstore(0x29a0, addmod(mload(0x2920), mload(0x2980), f_q))
            mstore(0x29c0, mulmod(mload(0xf20), mload(0xf20), f_q))
            mstore(0x29e0, mulmod(mload(0x29c0), mload(0xf20), f_q))
            mstore(0x2a00, mulmod(mload(0x29e0), mload(0xf20), f_q))
            mstore(0x2a20, mulmod(1, mload(0xf20), f_q))
            mstore(0x2a40, mulmod(1, mload(0x29c0), f_q))
            mstore(0x2a60, mulmod(1, mload(0x29e0), f_q))
            mstore(0x2a80, mulmod(mload(0x29a0), mload(0xf40), f_q))
            mstore(0x2aa0, mulmod(mload(0xc60), mload(0x7a0), f_q))
            mstore(0x2ac0, mulmod(mload(0x2aa0), mload(0x7a0), f_q))
            mstore(
                0x2ae0,
                mulmod(mload(0x7a0), 9741553891420464328295280489650144566903017206473301385034033384879943874347, f_q)
            )
            mstore(0x2b00, addmod(mload(0xb60), sub(f_q, mload(0x2ae0)), f_q))
            mstore(0x2b20, mulmod(mload(0x7a0), 1, f_q))
            mstore(0x2b40, addmod(mload(0xb60), sub(f_q, mload(0x2b20)), f_q))
            mstore(
                0x2b60,
                mulmod(mload(0x7a0), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            mstore(0x2b80, addmod(mload(0xb60), sub(f_q, mload(0x2b60)), f_q))
            mstore(
                0x2ba0,
                mulmod(mload(0x7a0), 11211301017135681023579411905410872569206244553457844956874280139879520583390, f_q)
            )
            mstore(0x2bc0, addmod(mload(0xb60), sub(f_q, mload(0x2ba0)), f_q))
            mstore(
                0x2be0,
                mulmod(mload(0x7a0), 3615478808282855240548287271348143516886772452944084747768312988864436725401, f_q)
            )
            mstore(0x2c00, addmod(mload(0xb60), sub(f_q, mload(0x2be0)), f_q))
            mstore(
                0x2c20,
                mulmod(
                    13213688729882003894512633350385593288217014177373218494356903340348818451480, mload(0x2aa0), f_q
                )
            )
            mstore(0x2c40, mulmod(mload(0x2c20), 1, f_q))
            {
                let result := mulmod(mload(0xb60), mload(0x2c20), f_q)
                result := addmod(mulmod(mload(0x7a0), sub(f_q, mload(0x2c40)), f_q), result, f_q)
                mstore(11360, result)
            }
            mstore(
                0x2c80,
                mulmod(8207090019724696496350398458716998472718344609680392612601596849934418295470, mload(0x2aa0), f_q)
            )
            mstore(
                0x2ca0,
                mulmod(mload(0x2c80), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            {
                let result := mulmod(mload(0xb60), mload(0x2c80), f_q)
                result := addmod(mulmod(mload(0x7a0), sub(f_q, mload(0x2ca0)), f_q), result, f_q)
                mstore(11456, result)
            }
            mstore(
                0x2ce0,
                mulmod(7391709068497399131897422873231908718558236401035363928063603272120120747483, mload(0x2aa0), f_q)
            )
            mstore(
                0x2d00,
                mulmod(
                    mload(0x2ce0), 11211301017135681023579411905410872569206244553457844956874280139879520583390, f_q
                )
            )
            {
                let result := mulmod(mload(0xb60), mload(0x2ce0), f_q)
                result := addmod(mulmod(mload(0x7a0), sub(f_q, mload(0x2d00)), f_q), result, f_q)
                mstore(11552, result)
            }
            mstore(
                0x2d40,
                mulmod(
                    19036273796805830823244991598792794567595348772040298280440552631112242221017, mload(0x2aa0), f_q
                )
            )
            mstore(
                0x2d60,
                mulmod(mload(0x2d40), 3615478808282855240548287271348143516886772452944084747768312988864436725401, f_q)
            )
            {
                let result := mulmod(mload(0xb60), mload(0x2d40), f_q)
                result := addmod(mulmod(mload(0x7a0), sub(f_q, mload(0x2d60)), f_q), result, f_q)
                mstore(11648, result)
            }
            mstore(0x2da0, mulmod(1, mload(0x2b40), f_q))
            mstore(0x2dc0, mulmod(mload(0x2da0), mload(0x2b80), f_q))
            mstore(0x2de0, mulmod(mload(0x2dc0), mload(0x2bc0), f_q))
            mstore(0x2e00, mulmod(mload(0x2de0), mload(0x2c00), f_q))
            mstore(
                0x2e20,
                mulmod(13513867906530865119835332133273263211836799082674232843258448413103731898271, mload(0x7a0), f_q)
            )
            mstore(0x2e40, mulmod(mload(0x2e20), 1, f_q))
            {
                let result := mulmod(mload(0xb60), mload(0x2e20), f_q)
                result := addmod(mulmod(mload(0x7a0), sub(f_q, mload(0x2e40)), f_q), result, f_q)
                mstore(11872, result)
            }
            mstore(
                0x2e80,
                mulmod(8374374965308410102411073611984011876711565317741801500439755773472076597346, mload(0x7a0), f_q)
            )
            mstore(
                0x2ea0,
                mulmod(mload(0x2e80), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            {
                let result := mulmod(mload(0xb60), mload(0x2e80), f_q)
                result := addmod(mulmod(mload(0x7a0), sub(f_q, mload(0x2ea0)), f_q), result, f_q)
                mstore(11968, result)
            }
            mstore(
                0x2ee0,
                mulmod(12146688980418810893951125255607130521645347193942732958664170801695864621271, mload(0x7a0), f_q)
            )
            mstore(0x2f00, mulmod(mload(0x2ee0), 1, f_q))
            {
                let result := mulmod(mload(0xb60), mload(0x2ee0), f_q)
                result := addmod(mulmod(mload(0x7a0), sub(f_q, mload(0x2f00)), f_q), result, f_q)
                mstore(12064, result)
            }
            mstore(
                0x2f40,
                mulmod(9741553891420464328295280489650144566903017206473301385034033384879943874346, mload(0x7a0), f_q)
            )
            mstore(
                0x2f60,
                mulmod(mload(0x2f40), 9741553891420464328295280489650144566903017206473301385034033384879943874347, f_q)
            )
            {
                let result := mulmod(mload(0xb60), mload(0x2f40), f_q)
                result := addmod(mulmod(mload(0x7a0), sub(f_q, mload(0x2f60)), f_q), result, f_q)
                mstore(12160, result)
            }
            mstore(0x2fa0, mulmod(mload(0x2da0), mload(0x2b00), f_q))
            {
                let result := mulmod(mload(0xb60), 1, f_q)
                result :=
                    addmod(
                        mulmod(
                            mload(0x7a0), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q
                        ),
                        result,
                        f_q
                    )
                mstore(12224, result)
            }
            {
                let prod := mload(0x2c60)

                prod := mulmod(mload(0x2cc0), prod, f_q)
                mstore(0x2fe0, prod)

                prod := mulmod(mload(0x2d20), prod, f_q)
                mstore(0x3000, prod)

                prod := mulmod(mload(0x2d80), prod, f_q)
                mstore(0x3020, prod)

                prod := mulmod(mload(0x2e60), prod, f_q)
                mstore(0x3040, prod)

                prod := mulmod(mload(0x2ec0), prod, f_q)
                mstore(0x3060, prod)

                prod := mulmod(mload(0x2dc0), prod, f_q)
                mstore(0x3080, prod)

                prod := mulmod(mload(0x2f20), prod, f_q)
                mstore(0x30a0, prod)

                prod := mulmod(mload(0x2f80), prod, f_q)
                mstore(0x30c0, prod)

                prod := mulmod(mload(0x2fa0), prod, f_q)
                mstore(0x30e0, prod)

                prod := mulmod(mload(0x2fc0), prod, f_q)
                mstore(0x3100, prod)

                prod := mulmod(mload(0x2da0), prod, f_q)
                mstore(0x3120, prod)
            }
            mstore(0x3160, 32)
            mstore(0x3180, 32)
            mstore(0x31a0, 32)
            mstore(0x31c0, mload(0x3120))
            mstore(0x31e0, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
            mstore(0x3200, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
            success := and(eq(staticcall(gas(), 0x5, 0x3160, 0xc0, 0x3140, 0x20), 1), success)
            {
                let inv := mload(0x3140)
                let v

                v := mload(0x2da0)
                mstore(11680, mulmod(mload(0x3100), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2fc0)
                mstore(12224, mulmod(mload(0x30e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2fa0)
                mstore(12192, mulmod(mload(0x30c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2f80)
                mstore(12160, mulmod(mload(0x30a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2f20)
                mstore(12064, mulmod(mload(0x3080), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2dc0)
                mstore(11712, mulmod(mload(0x3060), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2ec0)
                mstore(11968, mulmod(mload(0x3040), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2e60)
                mstore(11872, mulmod(mload(0x3020), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2d80)
                mstore(11648, mulmod(mload(0x3000), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2d20)
                mstore(11552, mulmod(mload(0x2fe0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2cc0)
                mstore(11456, mulmod(mload(0x2c60), inv, f_q))
                inv := mulmod(v, inv, f_q)
                mstore(0x2c60, inv)
            }
            {
                let result := mload(0x2c60)
                result := addmod(mload(0x2cc0), result, f_q)
                result := addmod(mload(0x2d20), result, f_q)
                result := addmod(mload(0x2d80), result, f_q)
                mstore(12832, result)
            }
            mstore(0x3240, mulmod(mload(0x2e00), mload(0x2dc0), f_q))
            {
                let result := mload(0x2e60)
                result := addmod(mload(0x2ec0), result, f_q)
                mstore(12896, result)
            }
            mstore(0x3280, mulmod(mload(0x2e00), mload(0x2fa0), f_q))
            {
                let result := mload(0x2f20)
                result := addmod(mload(0x2f80), result, f_q)
                mstore(12960, result)
            }
            mstore(0x32c0, mulmod(mload(0x2e00), mload(0x2da0), f_q))
            {
                let result := mload(0x2fc0)
                mstore(13024, result)
            }
            {
                let prod := mload(0x3220)

                prod := mulmod(mload(0x3260), prod, f_q)
                mstore(0x3300, prod)

                prod := mulmod(mload(0x32a0), prod, f_q)
                mstore(0x3320, prod)

                prod := mulmod(mload(0x32e0), prod, f_q)
                mstore(0x3340, prod)
            }
            mstore(0x3380, 32)
            mstore(0x33a0, 32)
            mstore(0x33c0, 32)
            mstore(0x33e0, mload(0x3340))
            mstore(0x3400, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
            mstore(0x3420, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
            success := and(eq(staticcall(gas(), 0x5, 0x3380, 0xc0, 0x3360, 0x20), 1), success)
            {
                let inv := mload(0x3360)
                let v

                v := mload(0x32e0)
                mstore(13024, mulmod(mload(0x3320), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x32a0)
                mstore(12960, mulmod(mload(0x3300), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3260)
                mstore(12896, mulmod(mload(0x3220), inv, f_q))
                inv := mulmod(v, inv, f_q)
                mstore(0x3220, inv)
            }
            mstore(0x3440, mulmod(mload(0x3240), mload(0x3260), f_q))
            mstore(0x3460, mulmod(mload(0x3280), mload(0x32a0), f_q))
            mstore(0x3480, mulmod(mload(0x32c0), mload(0x32e0), f_q))
            mstore(0x34a0, mulmod(mload(0xa60), mload(0xa60), f_q))
            mstore(0x34c0, mulmod(mload(0x34a0), mload(0xa60), f_q))
            mstore(0x34e0, mulmod(mload(0x34c0), mload(0xa60), f_q))
            mstore(0x3500, mulmod(mload(0x34e0), mload(0xa60), f_q))
            mstore(0x3520, mulmod(mload(0x3500), mload(0xa60), f_q))
            mstore(0x3540, mulmod(mload(0x3520), mload(0xa60), f_q))
            mstore(0x3560, mulmod(mload(0x3540), mload(0xa60), f_q))
            mstore(0x3580, mulmod(mload(0x3560), mload(0xa60), f_q))
            mstore(0x35a0, mulmod(mload(0x3580), mload(0xa60), f_q))
            mstore(0x35c0, mulmod(mload(0xac0), mload(0xac0), f_q))
            mstore(0x35e0, mulmod(mload(0x35c0), mload(0xac0), f_q))
            mstore(0x3600, mulmod(mload(0x35e0), mload(0xac0), f_q))
            {
                let result := mulmod(mload(0x7e0), mload(0x2c60), f_q)
                result := addmod(mulmod(mload(0x800), mload(0x2cc0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x820), mload(0x2d20), f_q), result, f_q)
                result := addmod(mulmod(mload(0x840), mload(0x2d80), f_q), result, f_q)
                mstore(13856, result)
            }
            mstore(0x3640, mulmod(mload(0x3620), mload(0x3220), f_q))
            mstore(0x3660, mulmod(sub(f_q, mload(0x3640)), 1, f_q))
            mstore(0x3680, mulmod(mload(0x3660), 1, f_q))
            mstore(0x36a0, mulmod(1, mload(0x3240), f_q))
            {
                let result := mulmod(mload(0x960), mload(0x2e60), f_q)
                result := addmod(mulmod(mload(0x980), mload(0x2ec0), f_q), result, f_q)
                mstore(14016, result)
            }
            mstore(0x36e0, mulmod(mload(0x36c0), mload(0x3440), f_q))
            mstore(0x3700, mulmod(sub(f_q, mload(0x36e0)), 1, f_q))
            mstore(0x3720, mulmod(mload(0x36a0), 1, f_q))
            {
                let result := mulmod(mload(0x9a0), mload(0x2e60), f_q)
                result := addmod(mulmod(mload(0x9c0), mload(0x2ec0), f_q), result, f_q)
                mstore(14144, result)
            }
            mstore(0x3760, mulmod(mload(0x3740), mload(0x3440), f_q))
            mstore(0x3780, mulmod(sub(f_q, mload(0x3760)), mload(0xa60), f_q))
            mstore(0x37a0, mulmod(mload(0x36a0), mload(0xa60), f_q))
            mstore(0x37c0, addmod(mload(0x3700), mload(0x3780), f_q))
            mstore(0x37e0, mulmod(mload(0x37c0), mload(0xac0), f_q))
            mstore(0x3800, mulmod(mload(0x3720), mload(0xac0), f_q))
            mstore(0x3820, mulmod(mload(0x37a0), mload(0xac0), f_q))
            mstore(0x3840, addmod(mload(0x3680), mload(0x37e0), f_q))
            mstore(0x3860, mulmod(1, mload(0x3280), f_q))
            {
                let result := mulmod(mload(0x9e0), mload(0x2f20), f_q)
                result := addmod(mulmod(mload(0xa00), mload(0x2f80), f_q), result, f_q)
                mstore(14464, result)
            }
            mstore(0x38a0, mulmod(mload(0x3880), mload(0x3460), f_q))
            mstore(0x38c0, mulmod(sub(f_q, mload(0x38a0)), 1, f_q))
            mstore(0x38e0, mulmod(mload(0x3860), 1, f_q))
            mstore(0x3900, mulmod(mload(0x38c0), mload(0x35c0), f_q))
            mstore(0x3920, mulmod(mload(0x38e0), mload(0x35c0), f_q))
            mstore(0x3940, addmod(mload(0x3840), mload(0x3900), f_q))
            mstore(0x3960, mulmod(1, mload(0x32c0), f_q))
            {
                let result := mulmod(mload(0xa20), mload(0x2fc0), f_q)
                mstore(14720, result)
            }
            mstore(0x39a0, mulmod(mload(0x3980), mload(0x3480), f_q))
            mstore(0x39c0, mulmod(sub(f_q, mload(0x39a0)), 1, f_q))
            mstore(0x39e0, mulmod(mload(0x3960), 1, f_q))
            {
                let result := mulmod(mload(0x860), mload(0x2fc0), f_q)
                mstore(14848, result)
            }
            mstore(0x3a20, mulmod(mload(0x3a00), mload(0x3480), f_q))
            mstore(0x3a40, mulmod(sub(f_q, mload(0x3a20)), mload(0xa60), f_q))
            mstore(0x3a60, mulmod(mload(0x3960), mload(0xa60), f_q))
            mstore(0x3a80, addmod(mload(0x39c0), mload(0x3a40), f_q))
            {
                let result := mulmod(mload(0x880), mload(0x2fc0), f_q)
                mstore(15008, result)
            }
            mstore(0x3ac0, mulmod(mload(0x3aa0), mload(0x3480), f_q))
            mstore(0x3ae0, mulmod(sub(f_q, mload(0x3ac0)), mload(0x34a0), f_q))
            mstore(0x3b00, mulmod(mload(0x3960), mload(0x34a0), f_q))
            mstore(0x3b20, addmod(mload(0x3a80), mload(0x3ae0), f_q))
            {
                let result := mulmod(mload(0x8a0), mload(0x2fc0), f_q)
                mstore(15168, result)
            }
            mstore(0x3b60, mulmod(mload(0x3b40), mload(0x3480), f_q))
            mstore(0x3b80, mulmod(sub(f_q, mload(0x3b60)), mload(0x34c0), f_q))
            mstore(0x3ba0, mulmod(mload(0x3960), mload(0x34c0), f_q))
            mstore(0x3bc0, addmod(mload(0x3b20), mload(0x3b80), f_q))
            {
                let result := mulmod(mload(0x8c0), mload(0x2fc0), f_q)
                mstore(15328, result)
            }
            mstore(0x3c00, mulmod(mload(0x3be0), mload(0x3480), f_q))
            mstore(0x3c20, mulmod(sub(f_q, mload(0x3c00)), mload(0x34e0), f_q))
            mstore(0x3c40, mulmod(mload(0x3960), mload(0x34e0), f_q))
            mstore(0x3c60, addmod(mload(0x3bc0), mload(0x3c20), f_q))
            {
                let result := mulmod(mload(0x900), mload(0x2fc0), f_q)
                mstore(15488, result)
            }
            mstore(0x3ca0, mulmod(mload(0x3c80), mload(0x3480), f_q))
            mstore(0x3cc0, mulmod(sub(f_q, mload(0x3ca0)), mload(0x3500), f_q))
            mstore(0x3ce0, mulmod(mload(0x3960), mload(0x3500), f_q))
            mstore(0x3d00, addmod(mload(0x3c60), mload(0x3cc0), f_q))
            {
                let result := mulmod(mload(0x920), mload(0x2fc0), f_q)
                mstore(15648, result)
            }
            mstore(0x3d40, mulmod(mload(0x3d20), mload(0x3480), f_q))
            mstore(0x3d60, mulmod(sub(f_q, mload(0x3d40)), mload(0x3520), f_q))
            mstore(0x3d80, mulmod(mload(0x3960), mload(0x3520), f_q))
            mstore(0x3da0, addmod(mload(0x3d00), mload(0x3d60), f_q))
            {
                let result := mulmod(mload(0x940), mload(0x2fc0), f_q)
                mstore(15808, result)
            }
            mstore(0x3de0, mulmod(mload(0x3dc0), mload(0x3480), f_q))
            mstore(0x3e00, mulmod(sub(f_q, mload(0x3de0)), mload(0x3540), f_q))
            mstore(0x3e20, mulmod(mload(0x3960), mload(0x3540), f_q))
            mstore(0x3e40, addmod(mload(0x3da0), mload(0x3e00), f_q))
            mstore(0x3e60, mulmod(mload(0x2a20), mload(0x32c0), f_q))
            mstore(0x3e80, mulmod(mload(0x2a40), mload(0x32c0), f_q))
            mstore(0x3ea0, mulmod(mload(0x2a60), mload(0x32c0), f_q))
            {
                let result := mulmod(mload(0x2a80), mload(0x2fc0), f_q)
                mstore(16064, result)
            }
            mstore(0x3ee0, mulmod(mload(0x3ec0), mload(0x3480), f_q))
            mstore(0x3f00, mulmod(sub(f_q, mload(0x3ee0)), mload(0x3560), f_q))
            mstore(0x3f20, mulmod(mload(0x3960), mload(0x3560), f_q))
            mstore(0x3f40, mulmod(mload(0x3e60), mload(0x3560), f_q))
            mstore(0x3f60, mulmod(mload(0x3e80), mload(0x3560), f_q))
            mstore(0x3f80, mulmod(mload(0x3ea0), mload(0x3560), f_q))
            mstore(0x3fa0, addmod(mload(0x3e40), mload(0x3f00), f_q))
            {
                let result := mulmod(mload(0x8e0), mload(0x2fc0), f_q)
                mstore(16320, result)
            }
            mstore(0x3fe0, mulmod(mload(0x3fc0), mload(0x3480), f_q))
            mstore(0x4000, mulmod(sub(f_q, mload(0x3fe0)), mload(0x3580), f_q))
            mstore(0x4020, mulmod(mload(0x3960), mload(0x3580), f_q))
            mstore(0x4040, addmod(mload(0x3fa0), mload(0x4000), f_q))
            mstore(0x4060, mulmod(mload(0x4040), mload(0x35e0), f_q))
            mstore(0x4080, mulmod(mload(0x39e0), mload(0x35e0), f_q))
            mstore(0x40a0, mulmod(mload(0x3a60), mload(0x35e0), f_q))
            mstore(0x40c0, mulmod(mload(0x3b00), mload(0x35e0), f_q))
            mstore(0x40e0, mulmod(mload(0x3ba0), mload(0x35e0), f_q))
            mstore(0x4100, mulmod(mload(0x3c40), mload(0x35e0), f_q))
            mstore(0x4120, mulmod(mload(0x3ce0), mload(0x35e0), f_q))
            mstore(0x4140, mulmod(mload(0x3d80), mload(0x35e0), f_q))
            mstore(0x4160, mulmod(mload(0x3e20), mload(0x35e0), f_q))
            mstore(0x4180, mulmod(mload(0x3f20), mload(0x35e0), f_q))
            mstore(0x41a0, mulmod(mload(0x3f40), mload(0x35e0), f_q))
            mstore(0x41c0, mulmod(mload(0x3f60), mload(0x35e0), f_q))
            mstore(0x41e0, mulmod(mload(0x3f80), mload(0x35e0), f_q))
            mstore(0x4200, mulmod(mload(0x4020), mload(0x35e0), f_q))
            mstore(0x4220, addmod(mload(0x3940), mload(0x4060), f_q))
            mstore(0x4240, mulmod(1, mload(0x2e00), f_q))
            mstore(0x4260, mulmod(1, mload(0xb60), f_q))
            mstore(0x4280, 0x0000000000000000000000000000000000000000000000000000000000000001)
            mstore(0x42a0, 0x0000000000000000000000000000000000000000000000000000000000000002)
            mstore(0x42c0, mload(0x4220))
            success := and(eq(staticcall(gas(), 0x7, 0x4280, 0x60, 0x4280, 0x40), 1), success)
            mstore(0x42e0, mload(0x4280))
            mstore(0x4300, mload(0x42a0))
            mstore(0x4320, mload(0x380))
            mstore(0x4340, mload(0x3a0))
            success := and(eq(staticcall(gas(), 0x6, 0x42e0, 0x80, 0x42e0, 0x40), 1), success)
            mstore(0x4360, mload(0x560))
            mstore(0x4380, mload(0x580))
            mstore(0x43a0, mload(0x3800))
            success := and(eq(staticcall(gas(), 0x7, 0x4360, 0x60, 0x4360, 0x40), 1), success)
            mstore(0x43c0, mload(0x42e0))
            mstore(0x43e0, mload(0x4300))
            mstore(0x4400, mload(0x4360))
            mstore(0x4420, mload(0x4380))
            success := and(eq(staticcall(gas(), 0x6, 0x43c0, 0x80, 0x43c0, 0x40), 1), success)
            mstore(0x4440, mload(0x5a0))
            mstore(0x4460, mload(0x5c0))
            mstore(0x4480, mload(0x3820))
            success := and(eq(staticcall(gas(), 0x7, 0x4440, 0x60, 0x4440, 0x40), 1), success)
            mstore(0x44a0, mload(0x43c0))
            mstore(0x44c0, mload(0x43e0))
            mstore(0x44e0, mload(0x4440))
            mstore(0x4500, mload(0x4460))
            success := and(eq(staticcall(gas(), 0x6, 0x44a0, 0x80, 0x44a0, 0x40), 1), success)
            mstore(0x4520, mload(0x420))
            mstore(0x4540, mload(0x440))
            mstore(0x4560, mload(0x3920))
            success := and(eq(staticcall(gas(), 0x7, 0x4520, 0x60, 0x4520, 0x40), 1), success)
            mstore(0x4580, mload(0x44a0))
            mstore(0x45a0, mload(0x44c0))
            mstore(0x45c0, mload(0x4520))
            mstore(0x45e0, mload(0x4540))
            success := and(eq(staticcall(gas(), 0x6, 0x4580, 0x80, 0x4580, 0x40), 1), success)
            mstore(0x4600, mload(0x460))
            mstore(0x4620, mload(0x480))
            mstore(0x4640, mload(0x4080))
            success := and(eq(staticcall(gas(), 0x7, 0x4600, 0x60, 0x4600, 0x40), 1), success)
            mstore(0x4660, mload(0x4580))
            mstore(0x4680, mload(0x45a0))
            mstore(0x46a0, mload(0x4600))
            mstore(0x46c0, mload(0x4620))
            success := and(eq(staticcall(gas(), 0x6, 0x4660, 0x80, 0x4660, 0x40), 1), success)
            mstore(0x46e0, 0x21b14b6e8ea36289961bde7f1d8f191389a815740d09f34f13190341383dfb13)
            mstore(0x4700, 0x16740f9c3982e02aeb0cb10086339afaca1bb103d5ae3f114c45a569d60c88ce)
            mstore(0x4720, mload(0x40a0))
            success := and(eq(staticcall(gas(), 0x7, 0x46e0, 0x60, 0x46e0, 0x40), 1), success)
            mstore(0x4740, mload(0x4660))
            mstore(0x4760, mload(0x4680))
            mstore(0x4780, mload(0x46e0))
            mstore(0x47a0, mload(0x4700))
            success := and(eq(staticcall(gas(), 0x6, 0x4740, 0x80, 0x4740, 0x40), 1), success)
            mstore(0x47c0, 0x2eb40e2b0c13a6f4b989cffa9dbc452447bfd9f04a79f6379aefea8c9850a550)
            mstore(0x47e0, 0x0efe5496541e2bd648d490f11ad542e1dec3127f818b8065843d0dd81358416c)
            mstore(0x4800, mload(0x40c0))
            success := and(eq(staticcall(gas(), 0x7, 0x47c0, 0x60, 0x47c0, 0x40), 1), success)
            mstore(0x4820, mload(0x4740))
            mstore(0x4840, mload(0x4760))
            mstore(0x4860, mload(0x47c0))
            mstore(0x4880, mload(0x47e0))
            success := and(eq(staticcall(gas(), 0x6, 0x4820, 0x80, 0x4820, 0x40), 1), success)
            mstore(0x48a0, 0x1c6707c73bce576eb360ffcb2fa9a0b17ad541ea0a0e8001439bca524f2f5a43)
            mstore(0x48c0, 0x03b899b999df6cf57b7755535b1dc5014a9dbd21d55c31d826d8338dc2fe8722)
            mstore(0x48e0, mload(0x40e0))
            success := and(eq(staticcall(gas(), 0x7, 0x48a0, 0x60, 0x48a0, 0x40), 1), success)
            mstore(0x4900, mload(0x4820))
            mstore(0x4920, mload(0x4840))
            mstore(0x4940, mload(0x48a0))
            mstore(0x4960, mload(0x48c0))
            success := and(eq(staticcall(gas(), 0x6, 0x4900, 0x80, 0x4900, 0x40), 1), success)
            mstore(0x4980, 0x1d309220cdb6694a08a8c77f89984557e19bbda422f41d50b47bf30b30b3dec3)
            mstore(0x49a0, 0x138c263b3cbc7de6f5f92f88c44a3e7fc278a4b69008db2340097131e43dbb1a)
            mstore(0x49c0, mload(0x4100))
            success := and(eq(staticcall(gas(), 0x7, 0x4980, 0x60, 0x4980, 0x40), 1), success)
            mstore(0x49e0, mload(0x4900))
            mstore(0x4a00, mload(0x4920))
            mstore(0x4a20, mload(0x4980))
            mstore(0x4a40, mload(0x49a0))
            success := and(eq(staticcall(gas(), 0x6, 0x49e0, 0x80, 0x49e0, 0x40), 1), success)
            mstore(0x4a60, 0x2529da4dfe20ec7564dc8738f2477daf565052f29117d9a2c1a0cbe846ab95fb)
            mstore(0x4a80, 0x2a3971e5a786b7e8b0039d1100621af00a8743921a36ef7aafc430b09a5bd279)
            mstore(0x4aa0, mload(0x4120))
            success := and(eq(staticcall(gas(), 0x7, 0x4a60, 0x60, 0x4a60, 0x40), 1), success)
            mstore(0x4ac0, mload(0x49e0))
            mstore(0x4ae0, mload(0x4a00))
            mstore(0x4b00, mload(0x4a60))
            mstore(0x4b20, mload(0x4a80))
            success := and(eq(staticcall(gas(), 0x6, 0x4ac0, 0x80, 0x4ac0, 0x40), 1), success)
            mstore(0x4b40, 0x132e1a4125c783ea4817ea96d967c5f06a49933ca71f7e99f7be022ef1e3ca35)
            mstore(0x4b60, 0x0eb726ae10479119d87b2e1d0d2b72db88506d263ae939b2154b0f3f5c7012f7)
            mstore(0x4b80, mload(0x4140))
            success := and(eq(staticcall(gas(), 0x7, 0x4b40, 0x60, 0x4b40, 0x40), 1), success)
            mstore(0x4ba0, mload(0x4ac0))
            mstore(0x4bc0, mload(0x4ae0))
            mstore(0x4be0, mload(0x4b40))
            mstore(0x4c00, mload(0x4b60))
            success := and(eq(staticcall(gas(), 0x6, 0x4ba0, 0x80, 0x4ba0, 0x40), 1), success)
            mstore(0x4c20, 0x1bc70a16efa4ef34c9ee86dc04d041fc8430240113b09ef71d5bbb8b685af6b7)
            mstore(0x4c40, 0x25064309a3b7ab3efd593b9e6c2f1294b50c12e237412186d7af94b1591dc937)
            mstore(0x4c60, mload(0x4160))
            success := and(eq(staticcall(gas(), 0x7, 0x4c20, 0x60, 0x4c20, 0x40), 1), success)
            mstore(0x4c80, mload(0x4ba0))
            mstore(0x4ca0, mload(0x4bc0))
            mstore(0x4cc0, mload(0x4c20))
            mstore(0x4ce0, mload(0x4c40))
            success := and(eq(staticcall(gas(), 0x6, 0x4c80, 0x80, 0x4c80, 0x40), 1), success)
            mstore(0x4d00, mload(0x680))
            mstore(0x4d20, mload(0x6a0))
            mstore(0x4d40, mload(0x4180))
            success := and(eq(staticcall(gas(), 0x7, 0x4d00, 0x60, 0x4d00, 0x40), 1), success)
            mstore(0x4d60, mload(0x4c80))
            mstore(0x4d80, mload(0x4ca0))
            mstore(0x4da0, mload(0x4d00))
            mstore(0x4dc0, mload(0x4d20))
            success := and(eq(staticcall(gas(), 0x6, 0x4d60, 0x80, 0x4d60, 0x40), 1), success)
            mstore(0x4de0, mload(0x6c0))
            mstore(0x4e00, mload(0x6e0))
            mstore(0x4e20, mload(0x41a0))
            success := and(eq(staticcall(gas(), 0x7, 0x4de0, 0x60, 0x4de0, 0x40), 1), success)
            mstore(0x4e40, mload(0x4d60))
            mstore(0x4e60, mload(0x4d80))
            mstore(0x4e80, mload(0x4de0))
            mstore(0x4ea0, mload(0x4e00))
            success := and(eq(staticcall(gas(), 0x6, 0x4e40, 0x80, 0x4e40, 0x40), 1), success)
            mstore(0x4ec0, mload(0x700))
            mstore(0x4ee0, mload(0x720))
            mstore(0x4f00, mload(0x41c0))
            success := and(eq(staticcall(gas(), 0x7, 0x4ec0, 0x60, 0x4ec0, 0x40), 1), success)
            mstore(0x4f20, mload(0x4e40))
            mstore(0x4f40, mload(0x4e60))
            mstore(0x4f60, mload(0x4ec0))
            mstore(0x4f80, mload(0x4ee0))
            success := and(eq(staticcall(gas(), 0x6, 0x4f20, 0x80, 0x4f20, 0x40), 1), success)
            mstore(0x4fa0, mload(0x740))
            mstore(0x4fc0, mload(0x760))
            mstore(0x4fe0, mload(0x41e0))
            success := and(eq(staticcall(gas(), 0x7, 0x4fa0, 0x60, 0x4fa0, 0x40), 1), success)
            mstore(0x5000, mload(0x4f20))
            mstore(0x5020, mload(0x4f40))
            mstore(0x5040, mload(0x4fa0))
            mstore(0x5060, mload(0x4fc0))
            success := and(eq(staticcall(gas(), 0x6, 0x5000, 0x80, 0x5000, 0x40), 1), success)
            mstore(0x5080, mload(0x5e0))
            mstore(0x50a0, mload(0x600))
            mstore(0x50c0, mload(0x4200))
            success := and(eq(staticcall(gas(), 0x7, 0x5080, 0x60, 0x5080, 0x40), 1), success)
            mstore(0x50e0, mload(0x5000))
            mstore(0x5100, mload(0x5020))
            mstore(0x5120, mload(0x5080))
            mstore(0x5140, mload(0x50a0))
            success := and(eq(staticcall(gas(), 0x6, 0x50e0, 0x80, 0x50e0, 0x40), 1), success)
            mstore(0x5160, mload(0xb00))
            mstore(0x5180, mload(0xb20))
            mstore(0x51a0, sub(f_q, mload(0x4240)))
            success := and(eq(staticcall(gas(), 0x7, 0x5160, 0x60, 0x5160, 0x40), 1), success)
            mstore(0x51c0, mload(0x50e0))
            mstore(0x51e0, mload(0x5100))
            mstore(0x5200, mload(0x5160))
            mstore(0x5220, mload(0x5180))
            success := and(eq(staticcall(gas(), 0x6, 0x51c0, 0x80, 0x51c0, 0x40), 1), success)
            mstore(0x5240, mload(0xba0))
            mstore(0x5260, mload(0xbc0))
            mstore(0x5280, mload(0x4260))
            success := and(eq(staticcall(gas(), 0x7, 0x5240, 0x60, 0x5240, 0x40), 1), success)
            mstore(0x52a0, mload(0x51c0))
            mstore(0x52c0, mload(0x51e0))
            mstore(0x52e0, mload(0x5240))
            mstore(0x5300, mload(0x5260))
            success := and(eq(staticcall(gas(), 0x6, 0x52a0, 0x80, 0x52a0, 0x40), 1), success)
            mstore(0x5320, mload(0x52a0))
            mstore(0x5340, mload(0x52c0))
            mstore(0x5360, mload(0xba0))
            mstore(0x5380, mload(0xbc0))
            mstore(0x53a0, mload(0xbe0))
            mstore(0x53c0, mload(0xc00))
            mstore(0x53e0, mload(0xc20))
            mstore(0x5400, mload(0xc40))
            mstore(0x5420, keccak256(0x5320, 256))
            mstore(21568, mod(mload(21536), f_q))
            mstore(0x5460, mulmod(mload(0x5440), mload(0x5440), f_q))
            mstore(0x5480, mulmod(1, mload(0x5440), f_q))
            mstore(0x54a0, mload(0x53a0))
            mstore(0x54c0, mload(0x53c0))
            mstore(0x54e0, mload(0x5480))
            success := and(eq(staticcall(gas(), 0x7, 0x54a0, 0x60, 0x54a0, 0x40), 1), success)
            mstore(0x5500, mload(0x5320))
            mstore(0x5520, mload(0x5340))
            mstore(0x5540, mload(0x54a0))
            mstore(0x5560, mload(0x54c0))
            success := and(eq(staticcall(gas(), 0x6, 0x5500, 0x80, 0x5500, 0x40), 1), success)
            mstore(0x5580, mload(0x53e0))
            mstore(0x55a0, mload(0x5400))
            mstore(0x55c0, mload(0x5480))
            success := and(eq(staticcall(gas(), 0x7, 0x5580, 0x60, 0x5580, 0x40), 1), success)
            mstore(0x55e0, mload(0x5360))
            mstore(0x5600, mload(0x5380))
            mstore(0x5620, mload(0x5580))
            mstore(0x5640, mload(0x55a0))
            success := and(eq(staticcall(gas(), 0x6, 0x55e0, 0x80, 0x55e0, 0x40), 1), success)
            mstore(0x5660, mload(0x5500))
            mstore(0x5680, mload(0x5520))
            mstore(0x56a0, 0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2)
            mstore(0x56c0, 0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed)
            mstore(0x56e0, 0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b)
            mstore(0x5700, 0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa)
            mstore(0x5720, mload(0x55e0))
            mstore(0x5740, mload(0x5600))
            mstore(0x5760, 0x172aa93c41f16e1e04d62ac976a5d945f4be0acab990c6dc19ac4a7cf68bf77b)
            mstore(0x5780, 0x2ae0c8c3a090f7200ff398ee9845bbae8f8c1445ae7b632212775f60a0e21600)
            mstore(0x57a0, 0x190fa476a5b352809ed41d7a0d7fe12b8f685e3c12a6d83855dba27aaf469643)
            mstore(0x57c0, 0x1c0a500618907df9e4273d5181e31088deb1f05132de037cbfe73888f97f77c9)
            success := and(eq(staticcall(gas(), 0x8, 0x5660, 0x180, 0x5660, 0x20), 1), success)
            success := and(eq(mload(0x5660), 1), success)

            // Revert if anything fails
            if iszero(success) { revert(0, 0) }

            // Return empty bytes on success
            return(0, 0)
        }
    }
}
