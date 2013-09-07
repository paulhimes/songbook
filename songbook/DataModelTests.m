//
//  DataModelTests.m
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "DataModelTests.h"
#import "Book+Helpers.h"
#import "Song+Helpers.h"
#import "Section+Helpers.h"
#import "Verse+Helpers.h"

@implementation DataModelTests

+ (void)populateSampleDataInContext:(NSManagedObjectContext *)context
{
    // Create the book.
    Book *book = [Book newOrExistingBookTitled:@"Songs & Hymns of Believers" inContext:context];
    
    // Create the sections.
    Section *songsSection = [Section newOrExistingSectionTitled:@"Songs of Believers" inBook:book];
    Section *finnSection = [Section newOrExistingSectionTitled:@"Uskovaisten Lauluja" inBook:book];
    Section *hymnSection = [Section newOrExistingSectionTitled:@"Hymns of Believers" inBook:book];

    // Create the songs.
    Song *song1 = [Song newOrExistingSongTitled:@"Oh How Lovely Is The Bride" inSection:songsSection];
    if ([song1.verses count] == 0) {
        song1.number = @1;
        song1.subtitle = @"(tune: 244 UL, O Kuinka Kaunis Ja Ihana)";
        [song1 addVerse:@"Oh how lovely is the Bride, Born of God never to die; In a beautiful gown so rare, Only the Angels here can wear."];
        [song1 addVerse:@"The wise men think it’s a mystery, They have eyes but cannot see; A Christmas tree from Heaven’s lot, Without blemish without spot."];
        [song1 addVerse:@"In a little town of Bethlehem, My Christmas gift was tucked away; In a lowly manger there, The Inns were crowded no one cared."];
        [song1 addVerse:@"God the Father placed Him there, He was in His Mother’s care; The Angles told the shepherds so, You’ll find Him in swaddling clothes."];
        [song1 addVerse:@"How many blessings did he bring? Oh that’s more than I can sing; Wisdom, redemption, salvation, Sanctification righteousness."];
        [song1 addVerse:@"Blessed children come to rest, Near the Mother’s loving breast; Lift your eyes and you can see, A slaughtered Lamb on Calvary."];
        [song1 addVerse:@"He sacrificed His life for sin, So that you and I can live; He came to be our daily bread, By His blood we are all fed."];
        [song1 addVerse:@"In His Kingdom He now reigns, Foundation is one great name; The name of Jesus written there, In the skies and everywhere."];
        [song1 addVerse:@"That is the place where all have gone, Who obeyed and loved the Lord; It is the city for the free, With a living Christmas tree."];
        [song1 addVerse:@"There the lame can walk and the dumb can talk, The blind can see the builder’s rock; On that rock we gather then, To sing our praises and Amen."];
        [song1 addVerse:@"God help me to keep my faith, Float my ark here on His grace; The flood of blood will carry me, Up to the Mount of the Olive Tree."];
        [song1 addVerse:@"Praise the Lord and sing to Him, Soon the wedding bells will ring; When the sin’s last atom falls, We can wait for the Shepherd’s call."];
        [song1 addVerse:@"When our God will shake this land, We will hear the Heaven’s band; So let’s stand fast on the rock ‘till then, Hallelujah and Amen."];
    }
    
    Song *song7 = [Song newOrExistingSongTitled:@"When My Life Work Is Ended" inSection:songsSection];
    if ([song7.verses count] == 0) {
        song7.number = @7;
        song7.subtitle = @"(tune: 162 UL, Kun On Markani Maara Kayty)";
        Verse *song7Verse1 = [song7 addVerse:@"When my life work is ended and I cross the swelling tide, When the bright and glorious morning I shall see; I shall know my Redeemer when I reach the other side, And his smile will be the first to welcome me."];
        song7Verse1.number = @1;
        Verse *song7Chorus1 = [song7 addVerse:@"I shall know Him, I shall know Him, As redeemed by his side I shall stand; I shall know Him, I shall know Him, By the prints of the nails in His hands."];
        song7Chorus1.number = nil;
        song7Chorus1.isChorus = @YES;
        Verse *song7Verse2 = [song7 addVerse:@"Oh the soul-thrilling rapture when I view His blessed face, And the luster of His kindly beaming eyes; How my full heart will praise Him for the mercy love and grace, That prepares for me a mansion in the sky."];
        song7Verse2.number = @2;
        song7Verse2.chorus = song7Chorus1;
        Verse *song7Verse3 = [song7 addVerse:@"Oh the dear ones in glory how they beckon me to come, Oh the parting at the river I recall; To the sweet vales of Eden they will sing my welcome home, But I long to meet my Saviour first of all."];
        song7Verse3.number = @3;
        song7Verse3.chorus = song7Chorus1;
        Verse *song7Verse4 = [song7 addVerse:@"Through the gates to the city in a robe of spotless white, He will lead me where no tears shall ever fall; In the glad song of ages I shall mingle with delight, but I long to meet my Saviour first of all."];
        song7Verse4.number = @4;
        song7Verse4.chorus = song7Chorus1;
    }
    
    Song *song41 = [Song newOrExistingSongTitled:@"My Wish Is To Praise God" inSection:songsSection];
    if ([song41.verses count] == 0) {
        song41.number = @41;
        song41.subtitle = @"(trans: 64 UL, Jo Mahtaisin Yota)";
        Verse *song41Verse1 = [song41 addVerse:@"My wish is to praise God night and day, For His great Love He showed toward us; That we’ve been made ready, For the great wedding, In Heaven with the Lamb of God."];
        song41Verse1.repeatText = @"That we’ve been made ready, For the great wedding, In Heaven with the Lamb of God.";
        Verse *song41Verse2 = [song41 addVerse:@"O boundless Love O endless grace, That I’ve been selected to be His Bride, For me this is plenty, That Jesus is mine, O endless grace and Love Divine."];
        song41Verse2.repeatText = @"For me this is plenty, That Jesus is mine, O endless grace and Love Divine.";
    }
    
    // Create the Finn Songs
    Song *finnSong0 = [Song newOrExistingSongTitled:@"O Jumalan Karitsa" inSection:finnSection];
    if ([finnSong0.verses count] == 0) {
        [finnSong0 addVerse:@"O Jumalan Karitsa! Joka pois otat maailman synnit, Armahda meidän päällemme!"];
        [finnSong0 addVerse:@"O Jumalan Karitsa! Joka pois otat maailman synnit, Armahda meidän päällemme!"];
        [finnSong0 addVerse:@"O Jumalan Karitsa! Joka pois otat maailman synnit, Anna meille rauhas ja siunaukses!"];
    }
    
    Song *finnSong40 = [Song newOrExistingSongTitled:@"Jo Mahtaisin Yötä Ja Päivääkin Kiitää" inSection:finnSection];
    if ([finnSong40.verses count] == 0) {
        finnSong40.number = @40;
        [finnSong40 addVerse:@"Jo mahtaisin jota ja päivääkin kiitää, Jumalan suurta hyvyyttä; Että saisimme taivassa häitämme viettää, Karitsan suuressa hovissa; Että saisimme taivassa häitämme viettää, Karitsan suuressa hovissa."];
        [finnSong40 addVerse:@"O rakkaus surri, O ääreton armo, että olla morsian Jeesukesen, Ja siinä on jo kyllä, Että Jeesus on mulla, O ääreton armo ja rakkaus; Ja siinä on jo kyllä, Että Jeesus on mulla, O ääreton armo ja rakkaus."];
        [finnSong40 addRelatedSongsObject:song41];
        [song41 addRelatedSongsObject:finnSong40];
    }
    
    // Create the Hymns
    Song *hymn72 = [Song newOrExistingSongTitled:@"Lord Dismiss Us With Thy Blessing" inSection:hymnSection];
    if ([hymn72.verses count] == 0) {
        hymn72.number = @72;
        [hymn72 addVerse:@"Lord dismiss us with Thy blessing, Fill our hearts with joy and peace; Let us each, Thy love possessing, Triumph in redeeming grace; Oh, refresh us, Oh, refresh us; Travelling through this wilderness."];
        [hymn72 addVerse:@"Thanks we give and adoration, For Thy Gospel’s joyful sound; May the fruits of Thy salvation, In our hearts and lives abound; Ever faithful, Ever faithful; To the truth may we be found."];
        [hymn72 addVerse:@"So whene’er the signal’s given, Us from earth to call away; Borne on Angel’s wings to Heaven, Glad Thy summons to obey; May we ever, May we ever; Reign with Christ in endless day."];
    }
    hymn72.author = @"John Fawcett";
    hymn72.year = @"1773";
    
    Song *hymn79 = [Song newOrExistingSongTitled:@"Trans: Hymn 56 UV, vs. 12 and 13" inSection:hymnSection];
    if ([hymn79.verses count] == 0) {
        hymn79.number = @79;
        Verse *hymn79Verse1 = [hymn79 addVerse:@"Recall my anguish, death and suffering, Which for your sake here I bore; While dying for you on the cross, Therefore making full atonement; All your debts I fully paid, Earned the Fathers’ Grace that day."];
        hymn79Verse1.title = @"Jesus";
        Verse *hymn79Verse2 = [hymn79 addVerse:@"With joy, dear Jesus, I do thank Thee, Because of Thy comforting love; Singing with a spiritual mind, As sin does no longer bind me; Thank Thee Father, Oh my soul, Everything is now fulfilled."];
        hymn79Verse2.title = @"Sinner";
    }
    
    // Save it all.
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"%@", error);
    };
}

+ (void)printBook:(Book *)book
{
    NSMutableString *string = [@"\n" mutableCopy];
    
    [string appendFormat:@"\n%@", book.title];
    for (Section *section in book.sections) {
        [string appendFormat:@"\n\n%@", section.title];
        
        for (Song *song in section.songs) {
            [string appendString:@"\n\n"];
            if (song.number) {
                [string appendFormat:@"%@ ", song.number];
            }
            [string appendString:song.title];
            if (song.subtitle) {
                [string appendFormat:@"\n%@", song.subtitle];
            }
            
            for (Verse *verse in song.verses) {
                [string appendString:@"\n\n"];
                if (verse.title) {
                    [string appendFormat:@"\t\t\t%@\n", verse.title];
                }
                if ([verse.isChorus boolValue]) {
                    [string appendFormat:@"Chorus: %@", verse.text];
                } else {
                    if (verse.number) {
                        [string appendFormat:@"%@. ", verse.number];
                    }
                    [string appendString:verse.text];
                }
            }
        }
    }
         
    NSLog(@"%@", string);
}

@end
