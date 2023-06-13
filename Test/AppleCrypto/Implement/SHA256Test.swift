//
//  SHA256Test.swift
//  SabyAppleCryptoTest
//
//  Created by WOF on 2023/02/17.
//

import XCTest
@testable import SabyAppleCrypto

final class SHA256Test: XCTestCase {
    func test__hash() {
        XCTAssertEqual(
            SHA256.hash(message: "test"),
            "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"
        )
        XCTAssertEqual(
            SHA256.hash(message: ""),
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        )
        XCTAssertEqual(
            SHA256.hash(message: "airbridge"),
            "db1386667799618d974aa48b62c8b1b1197bdcbcc97300236d594ad05519d72e"
        )
        XCTAssertEqual(
            SHA256.hash(message: "ab180"),
            "bf946198fb74d1b24d40e4c8d6f8608febe5a4c1211fb8778b29e459193b9fa3"
        )
        XCTAssertEqual(
            SHA256.hash(message: "😇"),
            "857b3a0bcf15ec034febcaa459703af6b3069ac279367e59c76764a17dbf38be"
        )
        XCTAssertEqual(
            SHA256.hash(message: "😇.ab180.co"),
            "b7b03d6265f3725976147208406cd5555e127756962d4e2eaaf1000f66f6e223"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://airbridge.io/"),
            "9dba4d16207df701612e8c7baa1d006acff56546098d7c1ba6b8dc84b2b181c9"
        )
        XCTAssertEqual(
            SHA256.hash(message: "ablog://main"),
            "86e9970c0813ab80cc519efe7e72c13a05b7c42391ea57f5512b9edc2a87b2de"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://user:password@airbridge.io:443?key=value#hash/"),
            "e5e3f3b36e6bd59429cf777ac620d7c8b1c006561944138de57f3d6ed4fb7aa3"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://:@airbridge.io:?#"),
            "f51500e3cfd20caca82e8f398e27883aec680df930471e78b9f000e373cde3db"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://user:@airbridge.io:?#"),
            "d265799bd737bf1f4cf87cc59e9e8197cb9ca9295d10dab624c04ab63ec183c6"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https"),
            "3e1943522517e81328e3f3f7ea1f0d7fc2ca886dfe1639a7fa6508760d1cee3a"
        )
        XCTAssertEqual(
            SHA256.hash(message: "file:"),
            "430473329df5ca205e93d09d202c021d973044142fe20fc4abf555135c405c44"
        )
        XCTAssertEqual(
            SHA256.hash(message: "123://airbridge.io"),
            "70c29fea188720ee3bc7f3aa1338cc334874216d77e0632bf7d5e232a0eaa366"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https:///"),
            "9e1c766935cd68d5fb6e0542c7384630df53f9ed9ab6c08785f1629b62408291"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://<>"),
            "c6a96d718a68f3604c666481737706171bceb67b33b1867947aba157a0289e97"
        )
        XCTAssertEqual(
            SHA256.hash(message: "ablog://<>"),
            "8e5decfad6b60592918f51c69a0857bdb1df63106a30d568bf8ebf45d53f3739"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://😇.ab180.co/"),
            "6146a39c381029915d336054e129ec748cbfe380439ebc4edab0b1f2cdb47838"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://😇😇😇😇😇.ab180.co/"),
            "b47fe3a2653770fdc0c065dc6d3b31e4de7e5ba37636b307acaaf3fd1ae2eb4c"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://😇develop😇.airbridge.io/"),
            "39eb68f149a308ad355e35211b099083fd62b4e0c683a89bf227e6d279d0e6bd"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://1."),
            "40fdb9249019e10f08a208fa9e1de332a038a731123c8d8edfdbc38186e11e14"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://1.1"),
            "f59983245809ef42c707ce1b2b24efcb4e8d23b55f6c448ad788a2032f533058"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://0x01.1"),
            "aa8f3ed3010f36bc34b1872030d6da987f97578d11a3d6ddbe508f65268c38bc"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://0x01.010.0.1"),
            "9949a636422a89045678b8c3310ef4177b5d15ca53b72fd81e99c1ef933b83a6"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://1.0xffff"),
            "92ea21f2c643ddfda20a7a30417f0fe77e1da04d2d2e81cdaf1e1d0a6dc764ee"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://0xffff."),
            "9bef3277db4e1aa9d5fc6d7e3d8c630422df62411b2249ba1ee9299dd57d3118"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://300.0.0.0"),
            "d5e078f2a94ba58c9e6138a8213653a4e8c525c938c2c3ade4130f12a0c55fdf"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://0.0.0xffffff"),
            "adb86c9b2db9ebb7e19e23c7efbc74e07e85e10946cc1db31967df7d3a70fffc"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://[::]"),
            "1c8708dbac36641a538643950dc5aed561b2211350d01562fefa40e2b67e7db9"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://[0:0:0:0:0:0:0:0]"),
            "33dd74bf865be3d83e11beab269398574e0a20e0c239b969b2dea01f77ddb18e"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://[0:0:1:1:0:0:0:0]"),
            "54c4d6a985778dd0581715060c988c3de46dcc1b55c65c5ad1eff41d24879a81"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://[0::1:0:0:0:1:0]"),
            "8b03e4346c4129211c7184ee9e491b47a4239a0de3461db7055cf5c81d67864d"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://[0::1:0:0:0:255.255.255.255]"),
            "c36f981f913ce72b866d2de9cfdc6fed0f4544ad534dd1cbce7af5c3f98d8065"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://[ff:ff:ff:ff:ff:ff:ff:ff]"),
            "e499f1377f627563a196ce0163b9d5d0fd28191187779973c889a221f08e74e5"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://[]"),
            "cb9d63515c50a28888be042efa3a0261fc14df60befdfa2b95999ac2e99bffcb"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://[::255.255.255.256]"),
            "b2e51f756f39bbe1fbe517f01bc016b9547a5afeae7699dc1cca5ed201c0dc49"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://airbridge.io:abc"),
            "52bf6d85f7f054eb091696f3b4837aa62c85bd6f047924f9d4340f44db1fca80"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://airbridge.io:443"),
            "c0dd3dc7e67a450cb9ed9b1c6acb248115b9093c3c5b0fbc272f88b59a2bb0d5"
        )
        XCTAssertEqual(
            SHA256.hash(message: "http://airbridge.io:80"),
            "3b9b3ea9b43a8ad5c4cd685614f21ec9240b30f901f7235d65a57eed84f9c5e1"
        )
        XCTAssertEqual(
            SHA256.hash(message: "ftp://airbridge.io:21"),
            "63ba506eb3c5ae843033028650efa8bfb7dd5eb20874457c9611bb1baf2236ff"
        )
        XCTAssertEqual(
            SHA256.hash(message: "file:c|"),
            "af36627f8e5d55e4b6d6303f9a2a5f0870074dfa8abd95d28dfdfcd8ae3f204b"
        )
        XCTAssertEqual(
            SHA256.hash(message: "file:c:/path"),
            "b421857a00eaf6cd0175d39ac93b47979ce41d1079781f152026873296423b3b"
        )
        XCTAssertEqual(
            SHA256.hash(message: "file:///c:/../path"),
            "5c0a2f535f128cc27fadb16a56f656545e237cbc7e95f1a4903d9df59057e3b5"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://airbridge.io/path/path/.././path/.."),
            "0048ba17ac58db87b0be38a321a845980da74f90b5ad60652009516fa94227c4"
        )
        XCTAssertEqual(
            SHA256.hash(message: "ablog:/abc/..//"),
            "7132eee31e844346ab61a47b2a4e1ff2f47b6de10eb37d7b23037ece0c88ba66"
        )
        XCTAssertEqual(
            SHA256.hash(message: "ablog:path"),
            "8e03081c45f54cc463f48d582db6a7874a681dc6d1c321b7e260a13754e47b6f"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://airbridge.io:8000"),
            "77e81bc1ad17a07482b462b3b55ef2adef374c04dfb760043cd84b319b937a83"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://airbridge.io/path/example"),
            "e169171299d9934839a7eea1319c825a55340b8f0dc198a9e35e29861b0fdc17"
        )
        XCTAssertEqual(
            SHA256.hash(message: "ablog://path/example"),
            "aee0c95bedbc033d63c1a63c3359eafa861fed9adee53d4196b06c49ed179724"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://airbridge.io/?key=value"),
            "a1faf473036967c4bccf0cd5e882d19845e864a48471a8d22acfee22a0b07349"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://airbridge.io/#hash"),
            "25f1364c901d6063aa079d5ad8df5a70cfdd8c8aa7293a81adee0b1380cda440"
        )
        XCTAssertEqual(
            SHA256.hash(message: "http://airbridge.io/"),
            "7a5e9f50ad1a592a2055535ed20afe2cc1e7736bd658b0d2726e1b856f007b7f"
        )
        XCTAssertEqual(
            SHA256.hash(message: "example://airbridge.io/"),
            "29396dadde7b12d0a7397b45bd5067509bd71d0d27c55e6b36e9d35ebde9f499"
        )
        XCTAssertEqual(
            SHA256.hash(message: "ablog://airbridge.io/"),
            "ce7c90558956ef937065147d1e85b2bda0ee4238a92a41bce16fd255da9204b9"
        )
        XCTAssertEqual(
            SHA256.hash(message: "file:///"),
            "de85814ad9cb4769a090f611dc4f82e7aa8aca812c00aa095d4ad459e8545880"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://user@airbridge.io/"),
            "b54bc805846d808cfdbf100821f7fa3866fbca34236fa31dde2fc33a06e1dfc3"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://:password@airbridge.io/"),
            "b421dd7fe9a2e388aa3f7e9797c0f222e7c8033f121622cf285fe83d82452f5a"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://airbridge.io:8000/"),
            "dc90160d078a761c10d670cb07eca27642b6ea451945f714ed0b1f255f4727b0"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://airbridge.io"),
            "f9efb201d706a4e8b908f0b7d9d899092fbc02246e21e7a21a18e80bc6d664d9"
        )
        XCTAssertEqual(
            SHA256.hash(message: "https://airbridge.io/path/"),
            "07513044d57cbba029e55e17f671a844f1b6b2e12099b5b352183063dc1d3e56"
        )
    }
}
