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
            mstore(0x380, mod(calldataload(0x2e0), f_q))
            mstore(0x3a0, mod(calldataload(0x300), f_q))
            mstore(0x3c0, mod(calldataload(0x320), f_q))
            mstore(0x80, 7401594839882027494765233667120903113724709862506427131570491288937814599202)

            {
                let x := calldataload(0x340)
                mstore(0x3e0, x)
                let y := calldataload(0x360)
                mstore(0x400, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x420, keccak256(0x80, 928))
            {
                let hash := mload(0x420)
                mstore(0x440, mod(hash, f_q))
                mstore(0x460, hash)
            }

            {
                let x := calldataload(0x380)
                mstore(0x480, x)
                let y := calldataload(0x3a0)
                mstore(0x4a0, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x3c0)
                mstore(0x4c0, x)
                let y := calldataload(0x3e0)
                mstore(0x4e0, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x500, keccak256(0x460, 160))
            {
                let hash := mload(0x500)
                mstore(0x520, mod(hash, f_q))
                mstore(0x540, hash)
            }
            mstore8(1376, 1)
            mstore(0x560, keccak256(0x540, 33))
            {
                let hash := mload(0x560)
                mstore(0x580, mod(hash, f_q))
                mstore(0x5a0, hash)
            }

            {
                let x := calldataload(0x400)
                mstore(0x5c0, x)
                let y := calldataload(0x420)
                mstore(0x5e0, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x440)
                mstore(0x600, x)
                let y := calldataload(0x460)
                mstore(0x620, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x480)
                mstore(0x640, x)
                let y := calldataload(0x4a0)
                mstore(0x660, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x680, keccak256(0x5a0, 224))
            {
                let hash := mload(0x680)
                mstore(0x6a0, mod(hash, f_q))
                mstore(0x6c0, hash)
            }

            {
                let x := calldataload(0x4c0)
                mstore(0x6e0, x)
                let y := calldataload(0x4e0)
                mstore(0x700, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x500)
                mstore(0x720, x)
                let y := calldataload(0x520)
                mstore(0x740, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x540)
                mstore(0x760, x)
                let y := calldataload(0x560)
                mstore(0x780, y)
                success := and(validate_ec_point(x, y), success)
            }

            {
                let x := calldataload(0x580)
                mstore(0x7a0, x)
                let y := calldataload(0x5a0)
                mstore(0x7c0, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0x7e0, keccak256(0x6c0, 288))
            {
                let hash := mload(0x7e0)
                mstore(0x800, mod(hash, f_q))
                mstore(0x820, hash)
            }
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
            mstore(0xa40, mod(calldataload(0x7c0), f_q))
            mstore(0xa60, mod(calldataload(0x7e0), f_q))
            mstore(0xa80, mod(calldataload(0x800), f_q))
            mstore(0xaa0, keccak256(0x820, 640))
            {
                let hash := mload(0xaa0)
                mstore(0xac0, mod(hash, f_q))
                mstore(0xae0, hash)
            }
            mstore8(2816, 1)
            mstore(0xb00, keccak256(0xae0, 33))
            {
                let hash := mload(0xb00)
                mstore(0xb20, mod(hash, f_q))
                mstore(0xb40, hash)
            }

            {
                let x := calldataload(0x820)
                mstore(0xb60, x)
                let y := calldataload(0x840)
                mstore(0xb80, y)
                success := and(validate_ec_point(x, y), success)
            }
            mstore(0xba0, keccak256(0xb40, 96))
            {
                let hash := mload(0xba0)
                mstore(0xbc0, mod(hash, f_q))
                mstore(0xbe0, hash)
            }

            {
                let x := calldataload(0x860)
                mstore(0xc00, x)
                let y := calldataload(0x880)
                mstore(0xc20, y)
                success := and(validate_ec_point(x, y), success)
            }
            {
                let x := mload(0xa0)
                x := add(x, shl(88, mload(0xc0)))
                x := add(x, shl(176, mload(0xe0)))
                mstore(3136, x)
                let y := mload(0x100)
                y := add(y, shl(88, mload(0x120)))
                y := add(y, shl(176, mload(0x140)))
                mstore(3168, y)

                success := and(validate_ec_point(x, y), success)
            }
            {
                let x := mload(0x160)
                x := add(x, shl(88, mload(0x180)))
                x := add(x, shl(176, mload(0x1a0)))
                mstore(3200, x)
                let y := mload(0x1c0)
                y := add(y, shl(88, mload(0x1e0)))
                y := add(y, shl(176, mload(0x200)))
                mstore(3232, y)

                success := and(validate_ec_point(x, y), success)
            }
            mstore(0xcc0, mulmod(mload(0x800), mload(0x800), f_q))
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
            mstore(0xf40, mulmod(mload(0xf20), mload(0xf20), f_q))
            mstore(0xf60, mulmod(mload(0xf40), mload(0xf40), f_q))
            mstore(0xf80, mulmod(mload(0xf60), mload(0xf60), f_q))
            mstore(
                0xfa0,
                addmod(mload(0xf80), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q)
            )
            mstore(
                0xfc0,
                mulmod(mload(0xfa0), 21888240262557392955334514970720457388010314637169927192662615958087340972065, f_q)
            )
            mstore(
                0xfe0,
                mulmod(mload(0xfc0), 4506835738822104338668100540817374747935106310012997856968187171738630203507, f_q)
            )
            mstore(
                0x1000,
                addmod(mload(0x800), 17381407133017170883578305204439900340613258090403036486730017014837178292110, f_q)
            )
            mstore(
                0x1020,
                mulmod(mload(0xfc0), 21710372849001950800533397158415938114909991150039389063546734567764856596059, f_q)
            )
            mstore(
                0x1040,
                addmod(mload(0x800), 177870022837324421713008586841336973638373250376645280151469618810951899558, f_q)
            )
            mstore(
                0x1060,
                mulmod(mload(0xfc0), 1887003188133998471169152042388914354640772748308168868301418279904560637395, f_q)
            )
            mstore(
                0x1080,
                addmod(mload(0x800), 20001239683705276751077253702868360733907591652107865475396785906671247858222, f_q)
            )
            mstore(
                0x10a0,
                mulmod(mload(0xfc0), 2785514556381676080176937710880804108647911392478702105860685610379369825016, f_q)
            )
            mstore(
                0x10c0,
                addmod(mload(0x800), 19102728315457599142069468034376470979900453007937332237837518576196438670601, f_q)
            )
            mstore(
                0x10e0,
                mulmod(mload(0xfc0), 14655294445420895451632927078981340937842238432098198055057679026789553137428, f_q)
            )
            mstore(
                0x1100,
                addmod(mload(0x800), 7232948426418379770613478666275934150706125968317836288640525159786255358189, f_q)
            )
            mstore(
                0x1120,
                mulmod(mload(0xfc0), 8734126352828345679573237859165904705806588461301144420590422589042130041188, f_q)
            )
            mstore(
                0x1140,
                addmod(mload(0x800), 13154116519010929542673167886091370382741775939114889923107781597533678454429, f_q)
            )
            mstore(
                0x1160,
                mulmod(mload(0xfc0), 9741553891420464328295280489650144566903017206473301385034033384879943874347, f_q)
            )
            mstore(
                0x1180,
                addmod(mload(0x800), 12146688980418810893951125255607130521645347193942732958664170801695864621270, f_q)
            )
            mstore(0x11a0, mulmod(mload(0xfc0), 1, f_q))
            mstore(
                0x11c0,
                addmod(mload(0x800), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q)
            )
            mstore(
                0x11e0,
                mulmod(mload(0xfc0), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            mstore(
                0x1200,
                addmod(mload(0x800), 13513867906530865119835332133273263211836799082674232843258448413103731898270, f_q)
            )
            mstore(
                0x1220,
                mulmod(mload(0xfc0), 11211301017135681023579411905410872569206244553457844956874280139879520583390, f_q)
            )
            mstore(
                0x1240,
                addmod(mload(0x800), 10676941854703594198666993839846402519342119846958189386823924046696287912227, f_q)
            )
            mstore(
                0x1260,
                mulmod(mload(0xfc0), 3615478808282855240548287271348143516886772452944084747768312988864436725401, f_q)
            )
            mstore(
                0x1280,
                addmod(mload(0x800), 18272764063556419981698118473909131571661591947471949595929891197711371770216, f_q)
            )
            mstore(
                0x12a0,
                mulmod(mload(0xfc0), 1426404432721484388505361748317961535523355871255605456897797744433766488507, f_q)
            )
            mstore(
                0x12c0,
                addmod(mload(0x800), 20461838439117790833741043996939313553025008529160428886800406442142042007110, f_q)
            )
            mstore(
                0x12e0,
                mulmod(mload(0xfc0), 216092043779272773661818549620449970334216366264741118684015851799902419467, f_q)
            )
            mstore(
                0x1300,
                addmod(mload(0x800), 21672150828060002448584587195636825118214148034151293225014188334775906076150, f_q)
            )
            mstore(
                0x1320,
                mulmod(mload(0xfc0), 12619617507853212586156872920672483948819476989779550311307282715684870266992, f_q)
            )
            mstore(
                0x1340,
                addmod(mload(0x800), 9268625363986062636089532824584791139728887410636484032390921470890938228625, f_q)
            )
            mstore(
                0x1360,
                mulmod(mload(0xfc0), 18610195890048912503953886742825279624920778288956610528523679659246523534888, f_q)
            )
            mstore(
                0x1380,
                addmod(mload(0x800), 3278046981790362718292519002431995463627586111459423815174524527329284960729, f_q)
            )
            mstore(
                0x13a0,
                mulmod(mload(0xfc0), 19032961837237948602743626455740240236231119053033140765040043513661803148152, f_q)
            )
            mstore(
                0x13c0,
                addmod(mload(0x800), 2855281034601326619502779289517034852317245347382893578658160672914005347465, f_q)
            )
            mstore(
                0x13e0,
                mulmod(mload(0xfc0), 14875928112196239563830800280253496262679717528621719058794366823499719730250, f_q)
            )
            mstore(
                0x1400,
                addmod(mload(0x800), 7012314759643035658415605465003778825868646871794315284903837363076088765367, f_q)
            )
            mstore(
                0x1420,
                mulmod(mload(0xfc0), 915149353520972163646494413843788069594022902357002628455555785223409501882, f_q)
            )
            mstore(
                0x1440,
                addmod(mload(0x800), 20973093518318303058599911331413487018954341498059031715242648401352398993735, f_q)
            )
            mstore(
                0x1460,
                mulmod(mload(0xfc0), 5522161504810533295870699551020523636289972223872138525048055197429246400245, f_q)
            )
            mstore(
                0x1480,
                addmod(mload(0x800), 16366081367028741926375706194236751452258392176543895818650148989146562095372, f_q)
            )
            mstore(
                0x14a0,
                mulmod(mload(0xfc0), 3766081621734395783232337525162072736827576297943013392955872170138036189193, f_q)
            )
            mstore(
                0x14c0,
                addmod(mload(0x800), 18122161250104879439014068220095202351720788102473020950742332016437772306424, f_q)
            )
            mstore(
                0x14e0,
                mulmod(mload(0xfc0), 9100833993744738801214480881117348002768153232283708533639316963648253510584, f_q)
            )
            mstore(
                0x1500,
                addmod(mload(0x800), 12787408878094536421031924864139927085780211168132325810058887222927554985033, f_q)
            )
            mstore(
                0x1520,
                mulmod(mload(0xfc0), 4245441013247250116003069945606352967193023389718465410501109428393342802981, f_q)
            )
            mstore(
                0x1540,
                addmod(mload(0x800), 17642801858592025106243335799650922121355341010697568933197094758182465692636, f_q)
            )
            mstore(
                0x1560,
                mulmod(mload(0xfc0), 6132660129994545119218258312491950835441607143741804980633129304664017206141, f_q)
            )
            mstore(
                0x1580,
                addmod(mload(0x800), 15755582741844730103028147432765324253106757256674229363065074881911791289476, f_q)
            )
            mstore(
                0x15a0,
                mulmod(mload(0xfc0), 5854133144571823792863860130267644613802765696134002830362054821530146160770, f_q)
            )
            mstore(
                0x15c0,
                addmod(mload(0x800), 16034109727267451429382545614989630474745598704282031513336149365045662334847, f_q)
            )
            mstore(
                0x15e0,
                mulmod(mload(0xfc0), 515148244606945972463850631189471072103916690263705052318085725998468254533, f_q)
            )
            mstore(
                0x1600,
                addmod(mload(0x800), 21373094627232329249782555114067804016444447710152329291380118460577340241084, f_q)
            )
            mstore(
                0x1620,
                mulmod(mload(0xfc0), 5980488956150442207659150513163747165544364597008566989111579977672498964212, f_q)
            )
            mstore(
                0x1640,
                addmod(mload(0x800), 15907753915688833014587255232093527923003999803407467354586624208903309531405, f_q)
            )
            mstore(
                0x1660,
                mulmod(mload(0xfc0), 5223738580615264174925218065001555728265216895679471490312087802465486318994, f_q)
            )
            mstore(
                0x1680,
                addmod(mload(0x800), 16664504291224011047321187680255719360283147504736562853386116384110322176623, f_q)
            )
            mstore(
                0x16a0,
                mulmod(mload(0xfc0), 14557038802599140430182096396825290815503940951075961210638273254419942783582, f_q)
            )
            mstore(
                0x16c0,
                addmod(mload(0x800), 7331204069240134792064309348431984273044423449340073133059930932155865712035, f_q)
            )
            mstore(
                0x16e0,
                mulmod(mload(0xfc0), 16976236069879939850923145256911338076234942200101755618884183331004076579046, f_q)
            )
            mstore(
                0x1700,
                addmod(mload(0x800), 4912006801959335371323260488345937012313422200314278724814020855571731916571, f_q)
            )
            mstore(
                0x1720,
                mulmod(mload(0xfc0), 13553911191894110065493137367144919847521088405945523452288398666974237857208, f_q)
            )
            mstore(
                0x1740,
                addmod(mload(0x800), 8334331679945165156753268378112355241027275994470510891409805519601570638409, f_q)
            )
            mstore(
                0x1760,
                mulmod(mload(0xfc0), 12222687719926148270818604386979005738180875192307070468454582955273533101023, f_q)
            )
            mstore(
                0x1780,
                addmod(mload(0x800), 9665555151913126951427801358278269350367489208108963875243621231302275394594, f_q)
            )
            mstore(
                0x17a0,
                mulmod(mload(0xfc0), 9697063347556872083384215826199993067635178715531258559890418744774301211662, f_q)
            )
            mstore(
                0x17c0,
                addmod(mload(0x800), 12191179524282403138862189919057282020913185684884775783807785441801507283955, f_q)
            )
            mstore(
                0x17e0,
                mulmod(mload(0xfc0), 13783318220968413117070077848579881425001701814458176881760898225529300547844, f_q)
            )
            mstore(
                0x1800,
                addmod(mload(0x800), 8104924650870862105176327896677393663546662585957857461937305961046507947773, f_q)
            )
            {
                let prod := mload(0x1000)

                prod := mulmod(mload(0x1040), prod, f_q)
                mstore(0x1820, prod)

                prod := mulmod(mload(0x1080), prod, f_q)
                mstore(0x1840, prod)

                prod := mulmod(mload(0x10c0), prod, f_q)
                mstore(0x1860, prod)

                prod := mulmod(mload(0x1100), prod, f_q)
                mstore(0x1880, prod)

                prod := mulmod(mload(0x1140), prod, f_q)
                mstore(0x18a0, prod)

                prod := mulmod(mload(0x1180), prod, f_q)
                mstore(0x18c0, prod)

                prod := mulmod(mload(0x11c0), prod, f_q)
                mstore(0x18e0, prod)

                prod := mulmod(mload(0x1200), prod, f_q)
                mstore(0x1900, prod)

                prod := mulmod(mload(0x1240), prod, f_q)
                mstore(0x1920, prod)

                prod := mulmod(mload(0x1280), prod, f_q)
                mstore(0x1940, prod)

                prod := mulmod(mload(0x12c0), prod, f_q)
                mstore(0x1960, prod)

                prod := mulmod(mload(0x1300), prod, f_q)
                mstore(0x1980, prod)

                prod := mulmod(mload(0x1340), prod, f_q)
                mstore(0x19a0, prod)

                prod := mulmod(mload(0x1380), prod, f_q)
                mstore(0x19c0, prod)

                prod := mulmod(mload(0x13c0), prod, f_q)
                mstore(0x19e0, prod)

                prod := mulmod(mload(0x1400), prod, f_q)
                mstore(0x1a00, prod)

                prod := mulmod(mload(0x1440), prod, f_q)
                mstore(0x1a20, prod)

                prod := mulmod(mload(0x1480), prod, f_q)
                mstore(0x1a40, prod)

                prod := mulmod(mload(0x14c0), prod, f_q)
                mstore(0x1a60, prod)

                prod := mulmod(mload(0x1500), prod, f_q)
                mstore(0x1a80, prod)

                prod := mulmod(mload(0x1540), prod, f_q)
                mstore(0x1aa0, prod)

                prod := mulmod(mload(0x1580), prod, f_q)
                mstore(0x1ac0, prod)

                prod := mulmod(mload(0x15c0), prod, f_q)
                mstore(0x1ae0, prod)

                prod := mulmod(mload(0x1600), prod, f_q)
                mstore(0x1b00, prod)

                prod := mulmod(mload(0x1640), prod, f_q)
                mstore(0x1b20, prod)

                prod := mulmod(mload(0x1680), prod, f_q)
                mstore(0x1b40, prod)

                prod := mulmod(mload(0x16c0), prod, f_q)
                mstore(0x1b60, prod)

                prod := mulmod(mload(0x1700), prod, f_q)
                mstore(0x1b80, prod)

                prod := mulmod(mload(0x1740), prod, f_q)
                mstore(0x1ba0, prod)

                prod := mulmod(mload(0x1780), prod, f_q)
                mstore(0x1bc0, prod)

                prod := mulmod(mload(0x17c0), prod, f_q)
                mstore(0x1be0, prod)

                prod := mulmod(mload(0x1800), prod, f_q)
                mstore(0x1c00, prod)

                prod := mulmod(mload(0xfa0), prod, f_q)
                mstore(0x1c20, prod)
            }
            mstore(0x1c60, 32)
            mstore(0x1c80, 32)
            mstore(0x1ca0, 32)
            mstore(0x1cc0, mload(0x1c20))
            mstore(0x1ce0, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
            mstore(0x1d00, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
            success := and(eq(staticcall(gas(), 0x5, 0x1c60, 0xc0, 0x1c40, 0x20), 1), success)
            {
                let inv := mload(0x1c40)
                let v

                v := mload(0xfa0)
                mstore(4000, mulmod(mload(0x1c00), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1800)
                mstore(6144, mulmod(mload(0x1be0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x17c0)
                mstore(6080, mulmod(mload(0x1bc0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1780)
                mstore(6016, mulmod(mload(0x1ba0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1740)
                mstore(5952, mulmod(mload(0x1b80), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1700)
                mstore(5888, mulmod(mload(0x1b60), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x16c0)
                mstore(5824, mulmod(mload(0x1b40), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1680)
                mstore(5760, mulmod(mload(0x1b20), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1640)
                mstore(5696, mulmod(mload(0x1b00), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1600)
                mstore(5632, mulmod(mload(0x1ae0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x15c0)
                mstore(5568, mulmod(mload(0x1ac0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1580)
                mstore(5504, mulmod(mload(0x1aa0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1540)
                mstore(5440, mulmod(mload(0x1a80), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1500)
                mstore(5376, mulmod(mload(0x1a60), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x14c0)
                mstore(5312, mulmod(mload(0x1a40), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1480)
                mstore(5248, mulmod(mload(0x1a20), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1440)
                mstore(5184, mulmod(mload(0x1a00), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1400)
                mstore(5120, mulmod(mload(0x19e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x13c0)
                mstore(5056, mulmod(mload(0x19c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1380)
                mstore(4992, mulmod(mload(0x19a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1340)
                mstore(4928, mulmod(mload(0x1980), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1300)
                mstore(4864, mulmod(mload(0x1960), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x12c0)
                mstore(4800, mulmod(mload(0x1940), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1280)
                mstore(4736, mulmod(mload(0x1920), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1240)
                mstore(4672, mulmod(mload(0x1900), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1200)
                mstore(4608, mulmod(mload(0x18e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x11c0)
                mstore(4544, mulmod(mload(0x18c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1180)
                mstore(4480, mulmod(mload(0x18a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1140)
                mstore(4416, mulmod(mload(0x1880), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1100)
                mstore(4352, mulmod(mload(0x1860), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x10c0)
                mstore(4288, mulmod(mload(0x1840), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1080)
                mstore(4224, mulmod(mload(0x1820), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x1040)
                mstore(4160, mulmod(mload(0x1000), inv, f_q))
                inv := mulmod(v, inv, f_q)
                mstore(0x1000, inv)
            }
            mstore(0x1d20, mulmod(mload(0xfe0), mload(0x1000), f_q))
            mstore(0x1d40, mulmod(mload(0x1020), mload(0x1040), f_q))
            mstore(0x1d60, mulmod(mload(0x1060), mload(0x1080), f_q))
            mstore(0x1d80, mulmod(mload(0x10a0), mload(0x10c0), f_q))
            mstore(0x1da0, mulmod(mload(0x10e0), mload(0x1100), f_q))
            mstore(0x1dc0, mulmod(mload(0x1120), mload(0x1140), f_q))
            mstore(0x1de0, mulmod(mload(0x1160), mload(0x1180), f_q))
            mstore(0x1e00, mulmod(mload(0x11a0), mload(0x11c0), f_q))
            mstore(0x1e20, mulmod(mload(0x11e0), mload(0x1200), f_q))
            mstore(0x1e40, mulmod(mload(0x1220), mload(0x1240), f_q))
            mstore(0x1e60, mulmod(mload(0x1260), mload(0x1280), f_q))
            mstore(0x1e80, mulmod(mload(0x12a0), mload(0x12c0), f_q))
            mstore(0x1ea0, mulmod(mload(0x12e0), mload(0x1300), f_q))
            mstore(0x1ec0, mulmod(mload(0x1320), mload(0x1340), f_q))
            mstore(0x1ee0, mulmod(mload(0x1360), mload(0x1380), f_q))
            mstore(0x1f00, mulmod(mload(0x13a0), mload(0x13c0), f_q))
            mstore(0x1f20, mulmod(mload(0x13e0), mload(0x1400), f_q))
            mstore(0x1f40, mulmod(mload(0x1420), mload(0x1440), f_q))
            mstore(0x1f60, mulmod(mload(0x1460), mload(0x1480), f_q))
            mstore(0x1f80, mulmod(mload(0x14a0), mload(0x14c0), f_q))
            mstore(0x1fa0, mulmod(mload(0x14e0), mload(0x1500), f_q))
            mstore(0x1fc0, mulmod(mload(0x1520), mload(0x1540), f_q))
            mstore(0x1fe0, mulmod(mload(0x1560), mload(0x1580), f_q))
            mstore(0x2000, mulmod(mload(0x15a0), mload(0x15c0), f_q))
            mstore(0x2020, mulmod(mload(0x15e0), mload(0x1600), f_q))
            mstore(0x2040, mulmod(mload(0x1620), mload(0x1640), f_q))
            mstore(0x2060, mulmod(mload(0x1660), mload(0x1680), f_q))
            mstore(0x2080, mulmod(mload(0x16a0), mload(0x16c0), f_q))
            mstore(0x20a0, mulmod(mload(0x16e0), mload(0x1700), f_q))
            mstore(0x20c0, mulmod(mload(0x1720), mload(0x1740), f_q))
            mstore(0x20e0, mulmod(mload(0x1760), mload(0x1780), f_q))
            mstore(0x2100, mulmod(mload(0x17a0), mload(0x17c0), f_q))
            mstore(0x2120, mulmod(mload(0x17e0), mload(0x1800), f_q))
            {
                let result := mulmod(mload(0x1e00), mload(0xa0), f_q)
                result := addmod(mulmod(mload(0x1e20), mload(0xc0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1e40), mload(0xe0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1e60), mload(0x100), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1e80), mload(0x120), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1ea0), mload(0x140), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1ec0), mload(0x160), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1ee0), mload(0x180), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1f00), mload(0x1a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1f20), mload(0x1c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1f40), mload(0x1e0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1f60), mload(0x200), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1f80), mload(0x220), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1fa0), mload(0x240), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1fc0), mload(0x260), f_q), result, f_q)
                result := addmod(mulmod(mload(0x1fe0), mload(0x280), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2000), mload(0x2a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2020), mload(0x2c0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2040), mload(0x2e0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2060), mload(0x300), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2080), mload(0x320), f_q), result, f_q)
                result := addmod(mulmod(mload(0x20a0), mload(0x340), f_q), result, f_q)
                result := addmod(mulmod(mload(0x20c0), mload(0x360), f_q), result, f_q)
                result := addmod(mulmod(mload(0x20e0), mload(0x380), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2100), mload(0x3a0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x2120), mload(0x3c0), f_q), result, f_q)
                mstore(8512, result)
            }
            mstore(0x2160, mulmod(mload(0x880), mload(0x860), f_q))
            mstore(0x2180, addmod(mload(0x840), mload(0x2160), f_q))
            mstore(0x21a0, addmod(mload(0x2180), sub(f_q, mload(0x8a0)), f_q))
            mstore(0x21c0, mulmod(mload(0x21a0), mload(0x900), f_q))
            mstore(0x21e0, mulmod(mload(0x6a0), mload(0x21c0), f_q))
            mstore(0x2200, addmod(1, sub(f_q, mload(0x9c0)), f_q))
            mstore(0x2220, mulmod(mload(0x2200), mload(0x1e00), f_q))
            mstore(0x2240, addmod(mload(0x21e0), mload(0x2220), f_q))
            mstore(0x2260, mulmod(mload(0x6a0), mload(0x2240), f_q))
            mstore(0x2280, mulmod(mload(0x9c0), mload(0x9c0), f_q))
            mstore(0x22a0, addmod(mload(0x2280), sub(f_q, mload(0x9c0)), f_q))
            mstore(0x22c0, mulmod(mload(0x22a0), mload(0x1d20), f_q))
            mstore(0x22e0, addmod(mload(0x2260), mload(0x22c0), f_q))
            mstore(0x2300, mulmod(mload(0x6a0), mload(0x22e0), f_q))
            mstore(0x2320, addmod(1, sub(f_q, mload(0x1d20)), f_q))
            mstore(0x2340, addmod(mload(0x1d40), mload(0x1d60), f_q))
            mstore(0x2360, addmod(mload(0x2340), mload(0x1d80), f_q))
            mstore(0x2380, addmod(mload(0x2360), mload(0x1da0), f_q))
            mstore(0x23a0, addmod(mload(0x2380), mload(0x1dc0), f_q))
            mstore(0x23c0, addmod(mload(0x23a0), mload(0x1de0), f_q))
            mstore(0x23e0, addmod(mload(0x2320), sub(f_q, mload(0x23c0)), f_q))
            mstore(0x2400, mulmod(mload(0x960), mload(0x520), f_q))
            mstore(0x2420, addmod(mload(0x8c0), mload(0x2400), f_q))
            mstore(0x2440, addmod(mload(0x2420), mload(0x580), f_q))
            mstore(0x2460, mulmod(mload(0x980), mload(0x520), f_q))
            mstore(0x2480, addmod(mload(0x840), mload(0x2460), f_q))
            mstore(0x24a0, addmod(mload(0x2480), mload(0x580), f_q))
            mstore(0x24c0, mulmod(mload(0x24a0), mload(0x2440), f_q))
            mstore(0x24e0, mulmod(mload(0x9a0), mload(0x520), f_q))
            mstore(0x2500, addmod(mload(0x2140), mload(0x24e0), f_q))
            mstore(0x2520, addmod(mload(0x2500), mload(0x580), f_q))
            mstore(0x2540, mulmod(mload(0x2520), mload(0x24c0), f_q))
            mstore(0x2560, mulmod(mload(0x2540), mload(0x9e0), f_q))
            mstore(0x2580, mulmod(1, mload(0x520), f_q))
            mstore(0x25a0, mulmod(mload(0x800), mload(0x2580), f_q))
            mstore(0x25c0, addmod(mload(0x8c0), mload(0x25a0), f_q))
            mstore(0x25e0, addmod(mload(0x25c0), mload(0x580), f_q))
            mstore(
                0x2600,
                mulmod(4131629893567559867359510883348571134090853742863529169391034518566172092834, mload(0x520), f_q)
            )
            mstore(0x2620, mulmod(mload(0x800), mload(0x2600), f_q))
            mstore(0x2640, addmod(mload(0x840), mload(0x2620), f_q))
            mstore(0x2660, addmod(mload(0x2640), mload(0x580), f_q))
            mstore(0x2680, mulmod(mload(0x2660), mload(0x25e0), f_q))
            mstore(
                0x26a0,
                mulmod(8910878055287538404433155982483128285667088683464058436815641868457422632747, mload(0x520), f_q)
            )
            mstore(0x26c0, mulmod(mload(0x800), mload(0x26a0), f_q))
            mstore(0x26e0, addmod(mload(0x2140), mload(0x26c0), f_q))
            mstore(0x2700, addmod(mload(0x26e0), mload(0x580), f_q))
            mstore(0x2720, mulmod(mload(0x2700), mload(0x2680), f_q))
            mstore(0x2740, mulmod(mload(0x2720), mload(0x9c0), f_q))
            mstore(0x2760, addmod(mload(0x2560), sub(f_q, mload(0x2740)), f_q))
            mstore(0x2780, mulmod(mload(0x2760), mload(0x23e0), f_q))
            mstore(0x27a0, addmod(mload(0x2300), mload(0x2780), f_q))
            mstore(0x27c0, mulmod(mload(0x6a0), mload(0x27a0), f_q))
            mstore(0x27e0, addmod(1, sub(f_q, mload(0xa00)), f_q))
            mstore(0x2800, mulmod(mload(0x27e0), mload(0x1e00), f_q))
            mstore(0x2820, addmod(mload(0x27c0), mload(0x2800), f_q))
            mstore(0x2840, mulmod(mload(0x6a0), mload(0x2820), f_q))
            mstore(0x2860, mulmod(mload(0xa00), mload(0xa00), f_q))
            mstore(0x2880, addmod(mload(0x2860), sub(f_q, mload(0xa00)), f_q))
            mstore(0x28a0, mulmod(mload(0x2880), mload(0x1d20), f_q))
            mstore(0x28c0, addmod(mload(0x2840), mload(0x28a0), f_q))
            mstore(0x28e0, mulmod(mload(0x6a0), mload(0x28c0), f_q))
            mstore(0x2900, addmod(mload(0xa40), mload(0x520), f_q))
            mstore(0x2920, mulmod(mload(0x2900), mload(0xa20), f_q))
            mstore(0x2940, addmod(mload(0xa80), mload(0x580), f_q))
            mstore(0x2960, mulmod(mload(0x2940), mload(0x2920), f_q))
            mstore(0x2980, mulmod(mload(0x840), mload(0x920), f_q))
            mstore(0x29a0, addmod(mload(0x2980), mload(0x520), f_q))
            mstore(0x29c0, mulmod(mload(0x29a0), mload(0xa00), f_q))
            mstore(0x29e0, addmod(mload(0x8e0), mload(0x580), f_q))
            mstore(0x2a00, mulmod(mload(0x29e0), mload(0x29c0), f_q))
            mstore(0x2a20, addmod(mload(0x2960), sub(f_q, mload(0x2a00)), f_q))
            mstore(0x2a40, mulmod(mload(0x2a20), mload(0x23e0), f_q))
            mstore(0x2a60, addmod(mload(0x28e0), mload(0x2a40), f_q))
            mstore(0x2a80, mulmod(mload(0x6a0), mload(0x2a60), f_q))
            mstore(0x2aa0, addmod(mload(0xa40), sub(f_q, mload(0xa80)), f_q))
            mstore(0x2ac0, mulmod(mload(0x2aa0), mload(0x1e00), f_q))
            mstore(0x2ae0, addmod(mload(0x2a80), mload(0x2ac0), f_q))
            mstore(0x2b00, mulmod(mload(0x6a0), mload(0x2ae0), f_q))
            mstore(0x2b20, mulmod(mload(0x2aa0), mload(0x23e0), f_q))
            mstore(0x2b40, addmod(mload(0xa40), sub(f_q, mload(0xa60)), f_q))
            mstore(0x2b60, mulmod(mload(0x2b40), mload(0x2b20), f_q))
            mstore(0x2b80, addmod(mload(0x2b00), mload(0x2b60), f_q))
            mstore(0x2ba0, mulmod(mload(0xf80), mload(0xf80), f_q))
            mstore(0x2bc0, mulmod(mload(0x2ba0), mload(0xf80), f_q))
            mstore(0x2be0, mulmod(mload(0x2bc0), mload(0xf80), f_q))
            mstore(0x2c00, mulmod(1, mload(0xf80), f_q))
            mstore(0x2c20, mulmod(1, mload(0x2ba0), f_q))
            mstore(0x2c40, mulmod(1, mload(0x2bc0), f_q))
            mstore(0x2c60, mulmod(mload(0x2b80), mload(0xfa0), f_q))
            mstore(0x2c80, mulmod(mload(0xcc0), mload(0x800), f_q))
            mstore(0x2ca0, mulmod(mload(0x2c80), mload(0x800), f_q))
            mstore(
                0x2cc0,
                mulmod(mload(0x800), 9741553891420464328295280489650144566903017206473301385034033384879943874347, f_q)
            )
            mstore(0x2ce0, addmod(mload(0xbc0), sub(f_q, mload(0x2cc0)), f_q))
            mstore(0x2d00, mulmod(mload(0x800), 1, f_q))
            mstore(0x2d20, addmod(mload(0xbc0), sub(f_q, mload(0x2d00)), f_q))
            mstore(
                0x2d40,
                mulmod(mload(0x800), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            mstore(0x2d60, addmod(mload(0xbc0), sub(f_q, mload(0x2d40)), f_q))
            mstore(
                0x2d80,
                mulmod(mload(0x800), 11211301017135681023579411905410872569206244553457844956874280139879520583390, f_q)
            )
            mstore(0x2da0, addmod(mload(0xbc0), sub(f_q, mload(0x2d80)), f_q))
            mstore(
                0x2dc0,
                mulmod(mload(0x800), 3615478808282855240548287271348143516886772452944084747768312988864436725401, f_q)
            )
            mstore(0x2de0, addmod(mload(0xbc0), sub(f_q, mload(0x2dc0)), f_q))
            mstore(
                0x2e00,
                mulmod(
                    13213688729882003894512633350385593288217014177373218494356903340348818451480, mload(0x2c80), f_q
                )
            )
            mstore(0x2e20, mulmod(mload(0x2e00), 1, f_q))
            {
                let result := mulmod(mload(0xbc0), mload(0x2e00), f_q)
                result := addmod(mulmod(mload(0x800), sub(f_q, mload(0x2e20)), f_q), result, f_q)
                mstore(11840, result)
            }
            mstore(
                0x2e60,
                mulmod(8207090019724696496350398458716998472718344609680392612601596849934418295470, mload(0x2c80), f_q)
            )
            mstore(
                0x2e80,
                mulmod(mload(0x2e60), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            {
                let result := mulmod(mload(0xbc0), mload(0x2e60), f_q)
                result := addmod(mulmod(mload(0x800), sub(f_q, mload(0x2e80)), f_q), result, f_q)
                mstore(11936, result)
            }
            mstore(
                0x2ec0,
                mulmod(7391709068497399131897422873231908718558236401035363928063603272120120747483, mload(0x2c80), f_q)
            )
            mstore(
                0x2ee0,
                mulmod(
                    mload(0x2ec0), 11211301017135681023579411905410872569206244553457844956874280139879520583390, f_q
                )
            )
            {
                let result := mulmod(mload(0xbc0), mload(0x2ec0), f_q)
                result := addmod(mulmod(mload(0x800), sub(f_q, mload(0x2ee0)), f_q), result, f_q)
                mstore(12032, result)
            }
            mstore(
                0x2f20,
                mulmod(
                    19036273796805830823244991598792794567595348772040298280440552631112242221017, mload(0x2c80), f_q
                )
            )
            mstore(
                0x2f40,
                mulmod(mload(0x2f20), 3615478808282855240548287271348143516886772452944084747768312988864436725401, f_q)
            )
            {
                let result := mulmod(mload(0xbc0), mload(0x2f20), f_q)
                result := addmod(mulmod(mload(0x800), sub(f_q, mload(0x2f40)), f_q), result, f_q)
                mstore(12128, result)
            }
            mstore(0x2f80, mulmod(1, mload(0x2d20), f_q))
            mstore(0x2fa0, mulmod(mload(0x2f80), mload(0x2d60), f_q))
            mstore(0x2fc0, mulmod(mload(0x2fa0), mload(0x2da0), f_q))
            mstore(0x2fe0, mulmod(mload(0x2fc0), mload(0x2de0), f_q))
            mstore(
                0x3000,
                mulmod(13513867906530865119835332133273263211836799082674232843258448413103731898271, mload(0x800), f_q)
            )
            mstore(0x3020, mulmod(mload(0x3000), 1, f_q))
            {
                let result := mulmod(mload(0xbc0), mload(0x3000), f_q)
                result := addmod(mulmod(mload(0x800), sub(f_q, mload(0x3020)), f_q), result, f_q)
                mstore(12352, result)
            }
            mstore(
                0x3060,
                mulmod(8374374965308410102411073611984011876711565317741801500439755773472076597346, mload(0x800), f_q)
            )
            mstore(
                0x3080,
                mulmod(mload(0x3060), 8374374965308410102411073611984011876711565317741801500439755773472076597347, f_q)
            )
            {
                let result := mulmod(mload(0xbc0), mload(0x3060), f_q)
                result := addmod(mulmod(mload(0x800), sub(f_q, mload(0x3080)), f_q), result, f_q)
                mstore(12448, result)
            }
            mstore(
                0x30c0,
                mulmod(12146688980418810893951125255607130521645347193942732958664170801695864621271, mload(0x800), f_q)
            )
            mstore(0x30e0, mulmod(mload(0x30c0), 1, f_q))
            {
                let result := mulmod(mload(0xbc0), mload(0x30c0), f_q)
                result := addmod(mulmod(mload(0x800), sub(f_q, mload(0x30e0)), f_q), result, f_q)
                mstore(12544, result)
            }
            mstore(
                0x3120,
                mulmod(9741553891420464328295280489650144566903017206473301385034033384879943874346, mload(0x800), f_q)
            )
            mstore(
                0x3140,
                mulmod(mload(0x3120), 9741553891420464328295280489650144566903017206473301385034033384879943874347, f_q)
            )
            {
                let result := mulmod(mload(0xbc0), mload(0x3120), f_q)
                result := addmod(mulmod(mload(0x800), sub(f_q, mload(0x3140)), f_q), result, f_q)
                mstore(12640, result)
            }
            mstore(0x3180, mulmod(mload(0x2f80), mload(0x2ce0), f_q))
            {
                let result := mulmod(mload(0xbc0), 1, f_q)
                result :=
                    addmod(
                        mulmod(
                            mload(0x800), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q
                        ),
                        result,
                        f_q
                    )
                mstore(12704, result)
            }
            {
                let prod := mload(0x2e40)

                prod := mulmod(mload(0x2ea0), prod, f_q)
                mstore(0x31c0, prod)

                prod := mulmod(mload(0x2f00), prod, f_q)
                mstore(0x31e0, prod)

                prod := mulmod(mload(0x2f60), prod, f_q)
                mstore(0x3200, prod)

                prod := mulmod(mload(0x3040), prod, f_q)
                mstore(0x3220, prod)

                prod := mulmod(mload(0x30a0), prod, f_q)
                mstore(0x3240, prod)

                prod := mulmod(mload(0x2fa0), prod, f_q)
                mstore(0x3260, prod)

                prod := mulmod(mload(0x3100), prod, f_q)
                mstore(0x3280, prod)

                prod := mulmod(mload(0x3160), prod, f_q)
                mstore(0x32a0, prod)

                prod := mulmod(mload(0x3180), prod, f_q)
                mstore(0x32c0, prod)

                prod := mulmod(mload(0x31a0), prod, f_q)
                mstore(0x32e0, prod)

                prod := mulmod(mload(0x2f80), prod, f_q)
                mstore(0x3300, prod)
            }
            mstore(0x3340, 32)
            mstore(0x3360, 32)
            mstore(0x3380, 32)
            mstore(0x33a0, mload(0x3300))
            mstore(0x33c0, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
            mstore(0x33e0, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
            success := and(eq(staticcall(gas(), 0x5, 0x3340, 0xc0, 0x3320, 0x20), 1), success)
            {
                let inv := mload(0x3320)
                let v

                v := mload(0x2f80)
                mstore(12160, mulmod(mload(0x32e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x31a0)
                mstore(12704, mulmod(mload(0x32c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3180)
                mstore(12672, mulmod(mload(0x32a0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3160)
                mstore(12640, mulmod(mload(0x3280), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3100)
                mstore(12544, mulmod(mload(0x3260), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2fa0)
                mstore(12192, mulmod(mload(0x3240), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x30a0)
                mstore(12448, mulmod(mload(0x3220), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3040)
                mstore(12352, mulmod(mload(0x3200), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2f60)
                mstore(12128, mulmod(mload(0x31e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2f00)
                mstore(12032, mulmod(mload(0x31c0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x2ea0)
                mstore(11936, mulmod(mload(0x2e40), inv, f_q))
                inv := mulmod(v, inv, f_q)
                mstore(0x2e40, inv)
            }
            {
                let result := mload(0x2e40)
                result := addmod(mload(0x2ea0), result, f_q)
                result := addmod(mload(0x2f00), result, f_q)
                result := addmod(mload(0x2f60), result, f_q)
                mstore(13312, result)
            }
            mstore(0x3420, mulmod(mload(0x2fe0), mload(0x2fa0), f_q))
            {
                let result := mload(0x3040)
                result := addmod(mload(0x30a0), result, f_q)
                mstore(13376, result)
            }
            mstore(0x3460, mulmod(mload(0x2fe0), mload(0x3180), f_q))
            {
                let result := mload(0x3100)
                result := addmod(mload(0x3160), result, f_q)
                mstore(13440, result)
            }
            mstore(0x34a0, mulmod(mload(0x2fe0), mload(0x2f80), f_q))
            {
                let result := mload(0x31a0)
                mstore(13504, result)
            }
            {
                let prod := mload(0x3400)

                prod := mulmod(mload(0x3440), prod, f_q)
                mstore(0x34e0, prod)

                prod := mulmod(mload(0x3480), prod, f_q)
                mstore(0x3500, prod)

                prod := mulmod(mload(0x34c0), prod, f_q)
                mstore(0x3520, prod)
            }
            mstore(0x3560, 32)
            mstore(0x3580, 32)
            mstore(0x35a0, 32)
            mstore(0x35c0, mload(0x3520))
            mstore(0x35e0, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
            mstore(0x3600, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
            success := and(eq(staticcall(gas(), 0x5, 0x3560, 0xc0, 0x3540, 0x20), 1), success)
            {
                let inv := mload(0x3540)
                let v

                v := mload(0x34c0)
                mstore(13504, mulmod(mload(0x3500), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3480)
                mstore(13440, mulmod(mload(0x34e0), inv, f_q))
                inv := mulmod(v, inv, f_q)

                v := mload(0x3440)
                mstore(13376, mulmod(mload(0x3400), inv, f_q))
                inv := mulmod(v, inv, f_q)
                mstore(0x3400, inv)
            }
            mstore(0x3620, mulmod(mload(0x3420), mload(0x3440), f_q))
            mstore(0x3640, mulmod(mload(0x3460), mload(0x3480), f_q))
            mstore(0x3660, mulmod(mload(0x34a0), mload(0x34c0), f_q))
            mstore(0x3680, mulmod(mload(0xac0), mload(0xac0), f_q))
            mstore(0x36a0, mulmod(mload(0x3680), mload(0xac0), f_q))
            mstore(0x36c0, mulmod(mload(0x36a0), mload(0xac0), f_q))
            mstore(0x36e0, mulmod(mload(0x36c0), mload(0xac0), f_q))
            mstore(0x3700, mulmod(mload(0x36e0), mload(0xac0), f_q))
            mstore(0x3720, mulmod(mload(0x3700), mload(0xac0), f_q))
            mstore(0x3740, mulmod(mload(0x3720), mload(0xac0), f_q))
            mstore(0x3760, mulmod(mload(0x3740), mload(0xac0), f_q))
            mstore(0x3780, mulmod(mload(0x3760), mload(0xac0), f_q))
            mstore(0x37a0, mulmod(mload(0xb20), mload(0xb20), f_q))
            mstore(0x37c0, mulmod(mload(0x37a0), mload(0xb20), f_q))
            mstore(0x37e0, mulmod(mload(0x37c0), mload(0xb20), f_q))
            {
                let result := mulmod(mload(0x840), mload(0x2e40), f_q)
                result := addmod(mulmod(mload(0x860), mload(0x2ea0), f_q), result, f_q)
                result := addmod(mulmod(mload(0x880), mload(0x2f00), f_q), result, f_q)
                result := addmod(mulmod(mload(0x8a0), mload(0x2f60), f_q), result, f_q)
                mstore(14336, result)
            }
            mstore(0x3820, mulmod(mload(0x3800), mload(0x3400), f_q))
            mstore(0x3840, mulmod(sub(f_q, mload(0x3820)), 1, f_q))
            mstore(0x3860, mulmod(mload(0x3840), 1, f_q))
            mstore(0x3880, mulmod(1, mload(0x3420), f_q))
            {
                let result := mulmod(mload(0x9c0), mload(0x3040), f_q)
                result := addmod(mulmod(mload(0x9e0), mload(0x30a0), f_q), result, f_q)
                mstore(14496, result)
            }
            mstore(0x38c0, mulmod(mload(0x38a0), mload(0x3620), f_q))
            mstore(0x38e0, mulmod(sub(f_q, mload(0x38c0)), 1, f_q))
            mstore(0x3900, mulmod(mload(0x3880), 1, f_q))
            {
                let result := mulmod(mload(0xa00), mload(0x3040), f_q)
                result := addmod(mulmod(mload(0xa20), mload(0x30a0), f_q), result, f_q)
                mstore(14624, result)
            }
            mstore(0x3940, mulmod(mload(0x3920), mload(0x3620), f_q))
            mstore(0x3960, mulmod(sub(f_q, mload(0x3940)), mload(0xac0), f_q))
            mstore(0x3980, mulmod(mload(0x3880), mload(0xac0), f_q))
            mstore(0x39a0, addmod(mload(0x38e0), mload(0x3960), f_q))
            mstore(0x39c0, mulmod(mload(0x39a0), mload(0xb20), f_q))
            mstore(0x39e0, mulmod(mload(0x3900), mload(0xb20), f_q))
            mstore(0x3a00, mulmod(mload(0x3980), mload(0xb20), f_q))
            mstore(0x3a20, addmod(mload(0x3860), mload(0x39c0), f_q))
            mstore(0x3a40, mulmod(1, mload(0x3460), f_q))
            {
                let result := mulmod(mload(0xa40), mload(0x3100), f_q)
                result := addmod(mulmod(mload(0xa60), mload(0x3160), f_q), result, f_q)
                mstore(14944, result)
            }
            mstore(0x3a80, mulmod(mload(0x3a60), mload(0x3640), f_q))
            mstore(0x3aa0, mulmod(sub(f_q, mload(0x3a80)), 1, f_q))
            mstore(0x3ac0, mulmod(mload(0x3a40), 1, f_q))
            mstore(0x3ae0, mulmod(mload(0x3aa0), mload(0x37a0), f_q))
            mstore(0x3b00, mulmod(mload(0x3ac0), mload(0x37a0), f_q))
            mstore(0x3b20, addmod(mload(0x3a20), mload(0x3ae0), f_q))
            mstore(0x3b40, mulmod(1, mload(0x34a0), f_q))
            {
                let result := mulmod(mload(0xa80), mload(0x31a0), f_q)
                mstore(15200, result)
            }
            mstore(0x3b80, mulmod(mload(0x3b60), mload(0x3660), f_q))
            mstore(0x3ba0, mulmod(sub(f_q, mload(0x3b80)), 1, f_q))
            mstore(0x3bc0, mulmod(mload(0x3b40), 1, f_q))
            {
                let result := mulmod(mload(0x8c0), mload(0x31a0), f_q)
                mstore(15328, result)
            }
            mstore(0x3c00, mulmod(mload(0x3be0), mload(0x3660), f_q))
            mstore(0x3c20, mulmod(sub(f_q, mload(0x3c00)), mload(0xac0), f_q))
            mstore(0x3c40, mulmod(mload(0x3b40), mload(0xac0), f_q))
            mstore(0x3c60, addmod(mload(0x3ba0), mload(0x3c20), f_q))
            {
                let result := mulmod(mload(0x8e0), mload(0x31a0), f_q)
                mstore(15488, result)
            }
            mstore(0x3ca0, mulmod(mload(0x3c80), mload(0x3660), f_q))
            mstore(0x3cc0, mulmod(sub(f_q, mload(0x3ca0)), mload(0x3680), f_q))
            mstore(0x3ce0, mulmod(mload(0x3b40), mload(0x3680), f_q))
            mstore(0x3d00, addmod(mload(0x3c60), mload(0x3cc0), f_q))
            {
                let result := mulmod(mload(0x900), mload(0x31a0), f_q)
                mstore(15648, result)
            }
            mstore(0x3d40, mulmod(mload(0x3d20), mload(0x3660), f_q))
            mstore(0x3d60, mulmod(sub(f_q, mload(0x3d40)), mload(0x36a0), f_q))
            mstore(0x3d80, mulmod(mload(0x3b40), mload(0x36a0), f_q))
            mstore(0x3da0, addmod(mload(0x3d00), mload(0x3d60), f_q))
            {
                let result := mulmod(mload(0x920), mload(0x31a0), f_q)
                mstore(15808, result)
            }
            mstore(0x3de0, mulmod(mload(0x3dc0), mload(0x3660), f_q))
            mstore(0x3e00, mulmod(sub(f_q, mload(0x3de0)), mload(0x36c0), f_q))
            mstore(0x3e20, mulmod(mload(0x3b40), mload(0x36c0), f_q))
            mstore(0x3e40, addmod(mload(0x3da0), mload(0x3e00), f_q))
            {
                let result := mulmod(mload(0x960), mload(0x31a0), f_q)
                mstore(15968, result)
            }
            mstore(0x3e80, mulmod(mload(0x3e60), mload(0x3660), f_q))
            mstore(0x3ea0, mulmod(sub(f_q, mload(0x3e80)), mload(0x36e0), f_q))
            mstore(0x3ec0, mulmod(mload(0x3b40), mload(0x36e0), f_q))
            mstore(0x3ee0, addmod(mload(0x3e40), mload(0x3ea0), f_q))
            {
                let result := mulmod(mload(0x980), mload(0x31a0), f_q)
                mstore(16128, result)
            }
            mstore(0x3f20, mulmod(mload(0x3f00), mload(0x3660), f_q))
            mstore(0x3f40, mulmod(sub(f_q, mload(0x3f20)), mload(0x3700), f_q))
            mstore(0x3f60, mulmod(mload(0x3b40), mload(0x3700), f_q))
            mstore(0x3f80, addmod(mload(0x3ee0), mload(0x3f40), f_q))
            {
                let result := mulmod(mload(0x9a0), mload(0x31a0), f_q)
                mstore(16288, result)
            }
            mstore(0x3fc0, mulmod(mload(0x3fa0), mload(0x3660), f_q))
            mstore(0x3fe0, mulmod(sub(f_q, mload(0x3fc0)), mload(0x3720), f_q))
            mstore(0x4000, mulmod(mload(0x3b40), mload(0x3720), f_q))
            mstore(0x4020, addmod(mload(0x3f80), mload(0x3fe0), f_q))
            mstore(0x4040, mulmod(mload(0x2c00), mload(0x34a0), f_q))
            mstore(0x4060, mulmod(mload(0x2c20), mload(0x34a0), f_q))
            mstore(0x4080, mulmod(mload(0x2c40), mload(0x34a0), f_q))
            {
                let result := mulmod(mload(0x2c60), mload(0x31a0), f_q)
                mstore(16544, result)
            }
            mstore(0x40c0, mulmod(mload(0x40a0), mload(0x3660), f_q))
            mstore(0x40e0, mulmod(sub(f_q, mload(0x40c0)), mload(0x3740), f_q))
            mstore(0x4100, mulmod(mload(0x3b40), mload(0x3740), f_q))
            mstore(0x4120, mulmod(mload(0x4040), mload(0x3740), f_q))
            mstore(0x4140, mulmod(mload(0x4060), mload(0x3740), f_q))
            mstore(0x4160, mulmod(mload(0x4080), mload(0x3740), f_q))
            mstore(0x4180, addmod(mload(0x4020), mload(0x40e0), f_q))
            {
                let result := mulmod(mload(0x940), mload(0x31a0), f_q)
                mstore(16800, result)
            }
            mstore(0x41c0, mulmod(mload(0x41a0), mload(0x3660), f_q))
            mstore(0x41e0, mulmod(sub(f_q, mload(0x41c0)), mload(0x3760), f_q))
            mstore(0x4200, mulmod(mload(0x3b40), mload(0x3760), f_q))
            mstore(0x4220, addmod(mload(0x4180), mload(0x41e0), f_q))
            mstore(0x4240, mulmod(mload(0x4220), mload(0x37c0), f_q))
            mstore(0x4260, mulmod(mload(0x3bc0), mload(0x37c0), f_q))
            mstore(0x4280, mulmod(mload(0x3c40), mload(0x37c0), f_q))
            mstore(0x42a0, mulmod(mload(0x3ce0), mload(0x37c0), f_q))
            mstore(0x42c0, mulmod(mload(0x3d80), mload(0x37c0), f_q))
            mstore(0x42e0, mulmod(mload(0x3e20), mload(0x37c0), f_q))
            mstore(0x4300, mulmod(mload(0x3ec0), mload(0x37c0), f_q))
            mstore(0x4320, mulmod(mload(0x3f60), mload(0x37c0), f_q))
            mstore(0x4340, mulmod(mload(0x4000), mload(0x37c0), f_q))
            mstore(0x4360, mulmod(mload(0x4100), mload(0x37c0), f_q))
            mstore(0x4380, mulmod(mload(0x4120), mload(0x37c0), f_q))
            mstore(0x43a0, mulmod(mload(0x4140), mload(0x37c0), f_q))
            mstore(0x43c0, mulmod(mload(0x4160), mload(0x37c0), f_q))
            mstore(0x43e0, mulmod(mload(0x4200), mload(0x37c0), f_q))
            mstore(0x4400, addmod(mload(0x3b20), mload(0x4240), f_q))
            mstore(0x4420, mulmod(1, mload(0x2fe0), f_q))
            mstore(0x4440, mulmod(1, mload(0xbc0), f_q))
            mstore(0x4460, 0x0000000000000000000000000000000000000000000000000000000000000001)
            mstore(0x4480, 0x0000000000000000000000000000000000000000000000000000000000000002)
            mstore(0x44a0, mload(0x4400))
            success := and(eq(staticcall(gas(), 0x7, 0x4460, 0x60, 0x4460, 0x40), 1), success)
            mstore(0x44c0, mload(0x4460))
            mstore(0x44e0, mload(0x4480))
            mstore(0x4500, mload(0x3e0))
            mstore(0x4520, mload(0x400))
            success := and(eq(staticcall(gas(), 0x6, 0x44c0, 0x80, 0x44c0, 0x40), 1), success)
            mstore(0x4540, mload(0x5c0))
            mstore(0x4560, mload(0x5e0))
            mstore(0x4580, mload(0x39e0))
            success := and(eq(staticcall(gas(), 0x7, 0x4540, 0x60, 0x4540, 0x40), 1), success)
            mstore(0x45a0, mload(0x44c0))
            mstore(0x45c0, mload(0x44e0))
            mstore(0x45e0, mload(0x4540))
            mstore(0x4600, mload(0x4560))
            success := and(eq(staticcall(gas(), 0x6, 0x45a0, 0x80, 0x45a0, 0x40), 1), success)
            mstore(0x4620, mload(0x600))
            mstore(0x4640, mload(0x620))
            mstore(0x4660, mload(0x3a00))
            success := and(eq(staticcall(gas(), 0x7, 0x4620, 0x60, 0x4620, 0x40), 1), success)
            mstore(0x4680, mload(0x45a0))
            mstore(0x46a0, mload(0x45c0))
            mstore(0x46c0, mload(0x4620))
            mstore(0x46e0, mload(0x4640))
            success := and(eq(staticcall(gas(), 0x6, 0x4680, 0x80, 0x4680, 0x40), 1), success)
            mstore(0x4700, mload(0x480))
            mstore(0x4720, mload(0x4a0))
            mstore(0x4740, mload(0x3b00))
            success := and(eq(staticcall(gas(), 0x7, 0x4700, 0x60, 0x4700, 0x40), 1), success)
            mstore(0x4760, mload(0x4680))
            mstore(0x4780, mload(0x46a0))
            mstore(0x47a0, mload(0x4700))
            mstore(0x47c0, mload(0x4720))
            success := and(eq(staticcall(gas(), 0x6, 0x4760, 0x80, 0x4760, 0x40), 1), success)
            mstore(0x47e0, mload(0x4c0))
            mstore(0x4800, mload(0x4e0))
            mstore(0x4820, mload(0x4260))
            success := and(eq(staticcall(gas(), 0x7, 0x47e0, 0x60, 0x47e0, 0x40), 1), success)
            mstore(0x4840, mload(0x4760))
            mstore(0x4860, mload(0x4780))
            mstore(0x4880, mload(0x47e0))
            mstore(0x48a0, mload(0x4800))
            success := and(eq(staticcall(gas(), 0x6, 0x4840, 0x80, 0x4840, 0x40), 1), success)
            mstore(0x48c0, 0x08cf72c06df0ac14416e0628b299a6a5069d04a2329ba10d42046429a072ca95)
            mstore(0x48e0, 0x1277cbc612f493274a612be5051dd6dbc544cbd6c8b6997e0811a372be8c09d0)
            mstore(0x4900, mload(0x4280))
            success := and(eq(staticcall(gas(), 0x7, 0x48c0, 0x60, 0x48c0, 0x40), 1), success)
            mstore(0x4920, mload(0x4840))
            mstore(0x4940, mload(0x4860))
            mstore(0x4960, mload(0x48c0))
            mstore(0x4980, mload(0x48e0))
            success := and(eq(staticcall(gas(), 0x6, 0x4920, 0x80, 0x4920, 0x40), 1), success)
            mstore(0x49a0, 0x14f9967686882b298d055eecfbeadcdaccdc11bb403d2595d9e009ea2fd4914b)
            mstore(0x49c0, 0x0f951ee95117ad514363247e2d918cbe010dc8a088ed831da215dd1667b233b4)
            mstore(0x49e0, mload(0x42a0))
            success := and(eq(staticcall(gas(), 0x7, 0x49a0, 0x60, 0x49a0, 0x40), 1), success)
            mstore(0x4a00, mload(0x4920))
            mstore(0x4a20, mload(0x4940))
            mstore(0x4a40, mload(0x49a0))
            mstore(0x4a60, mload(0x49c0))
            success := and(eq(staticcall(gas(), 0x6, 0x4a00, 0x80, 0x4a00, 0x40), 1), success)
            mstore(0x4a80, 0x1467e9edc904a2df82116b5da5ba48ca1bec3eb2bc436c7c0846868f36073095)
            mstore(0x4aa0, 0x27e9d9800c800450eb4e80186410af68dc493406eb89df9fbc1e5cef7838b0a2)
            mstore(0x4ac0, mload(0x42c0))
            success := and(eq(staticcall(gas(), 0x7, 0x4a80, 0x60, 0x4a80, 0x40), 1), success)
            mstore(0x4ae0, mload(0x4a00))
            mstore(0x4b00, mload(0x4a20))
            mstore(0x4b20, mload(0x4a80))
            mstore(0x4b40, mload(0x4aa0))
            success := and(eq(staticcall(gas(), 0x6, 0x4ae0, 0x80, 0x4ae0, 0x40), 1), success)
            mstore(0x4b60, 0x1e59fc6dc86d3482cce984d459a9c971b46f2a13159ef7da27021b0e46d700b4)
            mstore(0x4b80, 0x17276b525cbb9e81058ca0e72fc9d79cdf2daa293cc07996611c2c2b81092a36)
            mstore(0x4ba0, mload(0x42e0))
            success := and(eq(staticcall(gas(), 0x7, 0x4b60, 0x60, 0x4b60, 0x40), 1), success)
            mstore(0x4bc0, mload(0x4ae0))
            mstore(0x4be0, mload(0x4b00))
            mstore(0x4c00, mload(0x4b60))
            mstore(0x4c20, mload(0x4b80))
            success := and(eq(staticcall(gas(), 0x6, 0x4bc0, 0x80, 0x4bc0, 0x40), 1), success)
            mstore(0x4c40, 0x1790493da62a957d7e7779500c60c6125d723e73c4207ba6b4a3afa361bcf3fc)
            mstore(0x4c60, 0x2e753f63c4f529a4dced535d8ebf95d2397e5981996fd320572da6192fa2b2c9)
            mstore(0x4c80, mload(0x4300))
            success := and(eq(staticcall(gas(), 0x7, 0x4c40, 0x60, 0x4c40, 0x40), 1), success)
            mstore(0x4ca0, mload(0x4bc0))
            mstore(0x4cc0, mload(0x4be0))
            mstore(0x4ce0, mload(0x4c40))
            mstore(0x4d00, mload(0x4c60))
            success := and(eq(staticcall(gas(), 0x6, 0x4ca0, 0x80, 0x4ca0, 0x40), 1), success)
            mstore(0x4d20, 0x2ec1388da2436e0a92aaf7b61cdb2c5a58cc9dae44f8e4f2522d5a54c4783b3d)
            mstore(0x4d40, 0x0da2e38294eaf9dcbde03624fc0c549c965666e7ee52d99544248cc421cdb91b)
            mstore(0x4d60, mload(0x4320))
            success := and(eq(staticcall(gas(), 0x7, 0x4d20, 0x60, 0x4d20, 0x40), 1), success)
            mstore(0x4d80, mload(0x4ca0))
            mstore(0x4da0, mload(0x4cc0))
            mstore(0x4dc0, mload(0x4d20))
            mstore(0x4de0, mload(0x4d40))
            success := and(eq(staticcall(gas(), 0x6, 0x4d80, 0x80, 0x4d80, 0x40), 1), success)
            mstore(0x4e00, 0x2899585ab8aaf53e4208a7081c9d1f2c08e8fc6ff0d876aebfa2b62ec3240170)
            mstore(0x4e20, 0x10c3a81c8940e29ebcbe76871803db63b0fb0295fed4cab8cd93fea1cf3c8bb8)
            mstore(0x4e40, mload(0x4340))
            success := and(eq(staticcall(gas(), 0x7, 0x4e00, 0x60, 0x4e00, 0x40), 1), success)
            mstore(0x4e60, mload(0x4d80))
            mstore(0x4e80, mload(0x4da0))
            mstore(0x4ea0, mload(0x4e00))
            mstore(0x4ec0, mload(0x4e20))
            success := and(eq(staticcall(gas(), 0x6, 0x4e60, 0x80, 0x4e60, 0x40), 1), success)
            mstore(0x4ee0, mload(0x6e0))
            mstore(0x4f00, mload(0x700))
            mstore(0x4f20, mload(0x4360))
            success := and(eq(staticcall(gas(), 0x7, 0x4ee0, 0x60, 0x4ee0, 0x40), 1), success)
            mstore(0x4f40, mload(0x4e60))
            mstore(0x4f60, mload(0x4e80))
            mstore(0x4f80, mload(0x4ee0))
            mstore(0x4fa0, mload(0x4f00))
            success := and(eq(staticcall(gas(), 0x6, 0x4f40, 0x80, 0x4f40, 0x40), 1), success)
            mstore(0x4fc0, mload(0x720))
            mstore(0x4fe0, mload(0x740))
            mstore(0x5000, mload(0x4380))
            success := and(eq(staticcall(gas(), 0x7, 0x4fc0, 0x60, 0x4fc0, 0x40), 1), success)
            mstore(0x5020, mload(0x4f40))
            mstore(0x5040, mload(0x4f60))
            mstore(0x5060, mload(0x4fc0))
            mstore(0x5080, mload(0x4fe0))
            success := and(eq(staticcall(gas(), 0x6, 0x5020, 0x80, 0x5020, 0x40), 1), success)
            mstore(0x50a0, mload(0x760))
            mstore(0x50c0, mload(0x780))
            mstore(0x50e0, mload(0x43a0))
            success := and(eq(staticcall(gas(), 0x7, 0x50a0, 0x60, 0x50a0, 0x40), 1), success)
            mstore(0x5100, mload(0x5020))
            mstore(0x5120, mload(0x5040))
            mstore(0x5140, mload(0x50a0))
            mstore(0x5160, mload(0x50c0))
            success := and(eq(staticcall(gas(), 0x6, 0x5100, 0x80, 0x5100, 0x40), 1), success)
            mstore(0x5180, mload(0x7a0))
            mstore(0x51a0, mload(0x7c0))
            mstore(0x51c0, mload(0x43c0))
            success := and(eq(staticcall(gas(), 0x7, 0x5180, 0x60, 0x5180, 0x40), 1), success)
            mstore(0x51e0, mload(0x5100))
            mstore(0x5200, mload(0x5120))
            mstore(0x5220, mload(0x5180))
            mstore(0x5240, mload(0x51a0))
            success := and(eq(staticcall(gas(), 0x6, 0x51e0, 0x80, 0x51e0, 0x40), 1), success)
            mstore(0x5260, mload(0x640))
            mstore(0x5280, mload(0x660))
            mstore(0x52a0, mload(0x43e0))
            success := and(eq(staticcall(gas(), 0x7, 0x5260, 0x60, 0x5260, 0x40), 1), success)
            mstore(0x52c0, mload(0x51e0))
            mstore(0x52e0, mload(0x5200))
            mstore(0x5300, mload(0x5260))
            mstore(0x5320, mload(0x5280))
            success := and(eq(staticcall(gas(), 0x6, 0x52c0, 0x80, 0x52c0, 0x40), 1), success)
            mstore(0x5340, mload(0xb60))
            mstore(0x5360, mload(0xb80))
            mstore(0x5380, sub(f_q, mload(0x4420)))
            success := and(eq(staticcall(gas(), 0x7, 0x5340, 0x60, 0x5340, 0x40), 1), success)
            mstore(0x53a0, mload(0x52c0))
            mstore(0x53c0, mload(0x52e0))
            mstore(0x53e0, mload(0x5340))
            mstore(0x5400, mload(0x5360))
            success := and(eq(staticcall(gas(), 0x6, 0x53a0, 0x80, 0x53a0, 0x40), 1), success)
            mstore(0x5420, mload(0xc00))
            mstore(0x5440, mload(0xc20))
            mstore(0x5460, mload(0x4440))
            success := and(eq(staticcall(gas(), 0x7, 0x5420, 0x60, 0x5420, 0x40), 1), success)
            mstore(0x5480, mload(0x53a0))
            mstore(0x54a0, mload(0x53c0))
            mstore(0x54c0, mload(0x5420))
            mstore(0x54e0, mload(0x5440))
            success := and(eq(staticcall(gas(), 0x6, 0x5480, 0x80, 0x5480, 0x40), 1), success)
            mstore(0x5500, mload(0x5480))
            mstore(0x5520, mload(0x54a0))
            mstore(0x5540, mload(0xc00))
            mstore(0x5560, mload(0xc20))
            mstore(0x5580, mload(0xc40))
            mstore(0x55a0, mload(0xc60))
            mstore(0x55c0, mload(0xc80))
            mstore(0x55e0, mload(0xca0))
            mstore(0x5600, keccak256(0x5500, 256))
            mstore(22048, mod(mload(22016), f_q))
            mstore(0x5640, mulmod(mload(0x5620), mload(0x5620), f_q))
            mstore(0x5660, mulmod(1, mload(0x5620), f_q))
            mstore(0x5680, mload(0x5580))
            mstore(0x56a0, mload(0x55a0))
            mstore(0x56c0, mload(0x5660))
            success := and(eq(staticcall(gas(), 0x7, 0x5680, 0x60, 0x5680, 0x40), 1), success)
            mstore(0x56e0, mload(0x5500))
            mstore(0x5700, mload(0x5520))
            mstore(0x5720, mload(0x5680))
            mstore(0x5740, mload(0x56a0))
            success := and(eq(staticcall(gas(), 0x6, 0x56e0, 0x80, 0x56e0, 0x40), 1), success)
            mstore(0x5760, mload(0x55c0))
            mstore(0x5780, mload(0x55e0))
            mstore(0x57a0, mload(0x5660))
            success := and(eq(staticcall(gas(), 0x7, 0x5760, 0x60, 0x5760, 0x40), 1), success)
            mstore(0x57c0, mload(0x5540))
            mstore(0x57e0, mload(0x5560))
            mstore(0x5800, mload(0x5760))
            mstore(0x5820, mload(0x5780))
            success := and(eq(staticcall(gas(), 0x6, 0x57c0, 0x80, 0x57c0, 0x40), 1), success)
            mstore(0x5840, mload(0x56e0))
            mstore(0x5860, mload(0x5700))
            mstore(0x5880, 0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2)
            mstore(0x58a0, 0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed)
            mstore(0x58c0, 0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b)
            mstore(0x58e0, 0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa)
            mstore(0x5900, mload(0x57c0))
            mstore(0x5920, mload(0x57e0))
            mstore(0x5940, 0x138d5863615c12d3bd7d3fd007776d281a337f9d7f6dce23532100bb4bb5839d)
            mstore(0x5960, 0x0a3bb881671ee4e9238366e87f6598f0de356372ed3dc870766ec8ac005211e4)
            mstore(0x5980, 0x19c9d7d9c6e7ad2d9a0d5847ebdd2687c668939a202553ded2760d3eb8dbf559)
            mstore(0x59a0, 0x198adb441818c42721c88c532ed13a5da1ebb78b85574d0b7326d8e6f4c1e25a)
            success := and(eq(staticcall(gas(), 0x8, 0x5840, 0x180, 0x5840, 0x20), 1), success)
            success := and(eq(mload(0x5840), 1), success)

            // Revert if anything fails
            if iszero(success) { revert(0, 0) }

            // Return empty bytes on success
            return(0, 0)
        }
    }
}
