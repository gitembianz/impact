public
with sharing class CountryIsoUpdateHandler {
public
  static void countryIsoHandler(List<Account> theAccs) {
    List<Account> accs = new List<Account>();
    for (Account a : theAccs) {
      // Account theAcc = new Account();
      if (a.BillingCountry != null) {

        switch
          on a.BillingCountry {
            when 'Andorra' { a.Country_Code_EW__c = 'AD'; }
            when 'Emiratele Arabe Unite' { a.Country_Code_EW__c = 'AE'; }
            when 'Afganistan' { a.Country_Code_EW__c = 'AF'; }
            when 'Antigua şi Barbuda' { a.Country_Code_EW__c = 'AG'; }
            when 'Anguilla' { a.Country_Code_EW__c = 'AI'; }
            when 'Albania' { a.Country_Code_EW__c = 'AL'; }
            when 'Armenia' { a.Country_Code_EW__c = 'AM'; }
            when 'Angola' { a.Country_Code_EW__c = 'AO'; }
            when 'Antarctica' { a.Country_Code_EW__c = 'AQ'; }
            when 'Argentina' { a.Country_Code_EW__c = 'AR'; }
            when 'Samoa Americană' { a.Country_Code_EW__c = 'AS'; }
            when 'Austria' { a.Country_Code_EW__c = 'AT'; }
            when 'Australia' { a.Country_Code_EW__c = 'AU'; }
            when 'Aruba' { a.Country_Code_EW__c = 'AW'; }
            when 'Azerbaidjan' { a.Country_Code_EW__c = 'AZ'; }
            when 'Bosnia şi Herţegovina' { a.Country_Code_EW__c = 'BA'; }
            when 'Barbados' { a.Country_Code_EW__c = 'BB'; }
            when 'Bangladesh' { a.Country_Code_EW__c = 'BD'; }
            when 'Belgia' { a.Country_Code_EW__c = 'BE'; }
            when 'Burkina Faso' { a.Country_Code_EW__c = 'BF'; }
            when 'Bulgaria' { a.Country_Code_EW__c = 'BG'; }
            when 'Bahrain' { a.Country_Code_EW__c = 'BH'; }
            when 'Burundi' { a.Country_Code_EW__c = 'BI'; }
            when 'Benin' { a.Country_Code_EW__c = 'BJ'; }
            when 'Saint-Barthélemy' { a.Country_Code_EW__c = 'BL'; }
            when 'Bermuda' { a.Country_Code_EW__c = 'BM'; }
            when 'Statul Brunei Darussalam' { a.Country_Code_EW__c = 'BN'; }
            when 'Statul Plurinaţional al Boliviei' {
              a.Country_Code_EW__c = 'BO';
            }
            when 'Bonaire, Sint Eustatius şi Saba' { a.Country_Code_EW__c = 'BQ'; }
            when 'Brazilia' { a.Country_Code_EW__c = 'BR'; }
            when 'Bahamas' { a.Country_Code_EW__c = 'BS'; }
            when 'Bhutan' { a.Country_Code_EW__c = 'BT'; }
            when 'Insula Bouvet' { a.Country_Code_EW__c = 'BV'; }
            when 'Botswana' { a.Country_Code_EW__c = 'BW'; }
            when 'Belarus' { a.Country_Code_EW__c = 'BY'; }
            when 'Belize' { a.Country_Code_EW__c = 'BZ'; }
            when 'Canada' { a.Country_Code_EW__c = 'CA'; }
            when 'Insulele Cocos (sau Insulele Keeling)' {
              a.Country_Code_EW__c = 'CC';
            }
            when 'Republica Democratică Congo' { a.Country_Code_EW__c = 'CD'; }
            when 'Republica Centrafricană' { a.Country_Code_EW__c = 'CF'; }
            when 'Congo' { a.Country_Code_EW__c = 'CG'; }
            when 'Elveţia' { a.Country_Code_EW__c = 'CH'; }
            when 'Côte dIvoire' { a.Country_Code_EW__c = 'CI'; }
            when 'Insulele Cook' { a.Country_Code_EW__c = 'CK'; }
            when 'Chile' { a.Country_Code_EW__c = 'CL'; }
            when 'Camerun' { a.Country_Code_EW__c = 'CM'; }
            when 'China' { a.Country_Code_EW__c = 'CN'; }
            when 'Columbia' { a.Country_Code_EW__c = 'CO'; }
            when 'Costa Rica' { a.Country_Code_EW__c = 'CR'; }
            when 'Cuba' { a.Country_Code_EW__c = 'CU'; }
            when 'Capul Verde' { a.Country_Code_EW__c = 'CV'; }
            when 'Curaçao' { a.Country_Code_EW__c = 'CW'; }
            when 'Insula Christmas' { a.Country_Code_EW__c = 'CX'; }
            when 'Cipru' { a.Country_Code_EW__c = 'CY'; }
            when 'Republica Cehă' { a.Country_Code_EW__c = 'CZ'; }
            when 'Germania' { a.Country_Code_EW__c = 'DE'; }
            when 'Djibouti' { a.Country_Code_EW__c = 'DJ'; }
            when 'Danemarca' { a.Country_Code_EW__c = 'DK'; }
            when 'Dominica' { a.Country_Code_EW__c = 'DM'; }
            when 'Republica Dominicană' { a.Country_Code_EW__c = 'DO'; }
            when 'Algeria' { a.Country_Code_EW__c = 'DZ'; }
            when 'Ecuador' { a.Country_Code_EW__c = 'EC'; }
            when 'Estonia' { a.Country_Code_EW__c = 'EE'; }
            when 'Egipt' { a.Country_Code_EW__c = 'EG'; }
            when 'Sahara Occidentală' { a.Country_Code_EW__c = 'EH'; }
            when 'Eritreea' { a.Country_Code_EW__c = 'ER'; }
            when 'Spania' { a.Country_Code_EW__c = 'ES'; }
            when 'Etiopia' { a.Country_Code_EW__c = 'ET'; }
            when 'Finlanda' { a.Country_Code_EW__c = 'FI'; }
            when 'Fiji' { a.Country_Code_EW__c = 'FJ'; }
            when 'Insulele Falkland' { a.Country_Code_EW__c = 'FK'; }
            when 'Statele Federale ale Microneziei' {
              a.Country_Code_EW__c = 'FM';
            }
            when 'Insulele Feroe' { a.Country_Code_EW__c = 'FO'; }
            when 'Franţa' { a.Country_Code_EW__c = 'FR'; }
            when 'Gabon' { a.Country_Code_EW__c = 'GA'; }
            when 'Regatul Unit (Irlanda de Nord)' { a.Country_Code_EW__c = 'XI'; }
            when 'Regatul Unit (cu excepția Irlandei de Nord)' {
              a.Country_Code_EW__c = 'XU';
            }
            when 'Grenada' { a.Country_Code_EW__c = 'GD'; }
            when 'Georgia' { a.Country_Code_EW__c = 'GE'; }
            when 'Ghana' { a.Country_Code_EW__c = 'GH'; }
            when 'Gibraltar' { a.Country_Code_EW__c = 'GI'; }
            when 'Groenlanda' { a.Country_Code_EW__c = 'GL'; }
            when 'Gambia' { a.Country_Code_EW__c = 'GM'; }
            when 'Guineea' { a.Country_Code_EW__c = 'GN'; }
            when 'Guineea Ecuatorială' { a.Country_Code_EW__c = 'GQ'; }
            when 'Grecia' { a.Country_Code_EW__c = 'GR'; }
            when 'Georgia de Sud şi Insulele Sandwich de Sud' {
              a.Country_Code_EW__c = 'GS';
            }
            when 'Guatemala' { a.Country_Code_EW__c = 'GT'; }
            when 'Guam' { a.Country_Code_EW__c = 'GU'; }
            when 'Guineea-Bissau' { a.Country_Code_EW__c = 'GW'; }
            when 'Guyana' { a.Country_Code_EW__c = 'GY'; }
            when 'Hong Kong' { a.Country_Code_EW__c = 'HK'; }
            when 'Insula Heard şi Insulele McDonald' {
              a.Country_Code_EW__c = 'HM';
            }
            when 'Honduras' { a.Country_Code_EW__c = 'HN'; }
            when 'Croaţia' { a.Country_Code_EW__c = 'HR'; }
            when 'Haiti' { a.Country_Code_EW__c = 'HT'; }
            when 'Ungaria' { a.Country_Code_EW__c = 'HU'; }
            when 'Indonezia' { a.Country_Code_EW__c = 'ID'; }
            when 'Irlanda' { a.Country_Code_EW__c = 'IE'; }
            when 'Israel' { a.Country_Code_EW__c = 'IL'; }
            when 'India' { a.Country_Code_EW__c = 'IN'; }
            when 'Teritoriul Britanic din Oceanul Indian' {
              a.Country_Code_EW__c = 'IO';
            }
            when 'Irak' { a.Country_Code_EW__c = 'IQ'; }
            when 'Republica Islamică Iran' { a.Country_Code_EW__c = 'IR'; }
            when 'Islanda' { a.Country_Code_EW__c = 'IS'; }
            when 'Italia' { a.Country_Code_EW__c = 'IT'; }
            when 'Jamaica' { a.Country_Code_EW__c = 'JM'; }
            when 'Iordania' { a.Country_Code_EW__c = 'JO'; }
            when 'Japonia' { a.Country_Code_EW__c = 'JP'; }
            when 'Kenya' { a.Country_Code_EW__c = 'KE'; }
            when 'Republica Kârgâzstan' { a.Country_Code_EW__c = 'KG'; }
            when 'Cambodgia' { a.Country_Code_EW__c = 'KH'; }
            when 'Kiribati' { a.Country_Code_EW__c = 'KI'; }
            when 'Comore' { a.Country_Code_EW__c = 'KM'; }
            when 'Saint Kitts şi Nevis' { a.Country_Code_EW__c = 'KN'; }
            when 'Republica Populară Democrată Coreeană' {
              a.Country_Code_EW__c = 'KP';
            }
            when 'Republica Coreea' { a.Country_Code_EW__c = 'KR'; }
            when 'Kuweit' { a.Country_Code_EW__c = 'KW'; }
            when 'Insulele Cayman' { a.Country_Code_EW__c = 'KY'; }
            when 'Kazahstan' { a.Country_Code_EW__c = 'KZ'; }
            when 'Republica Democrată Populară Laos' {
              a.Country_Code_EW__c = 'LA';
            }
            when 'Liban' { a.Country_Code_EW__c = 'LB'; }
            when 'Saint Lucia' { a.Country_Code_EW__c = 'LC'; }
            when 'Liechtenstein' { a.Country_Code_EW__c = 'LI'; }
            when 'Sri Lanka' { a.Country_Code_EW__c = 'LK'; }
            when 'Liberia' { a.Country_Code_EW__c = 'LR'; }
            when 'Lesotho' { a.Country_Code_EW__c = 'LS'; }
            when 'Lituania' { a.Country_Code_EW__c = 'LT'; }
            when 'Luxemburg' { a.Country_Code_EW__c = 'LU'; }
            when 'Letonia' { a.Country_Code_EW__c = 'LV'; }
            when 'Libia' { a.Country_Code_EW__c = 'LY'; }
            when 'Maroc' { a.Country_Code_EW__c = 'MA'; }
            when 'Republica Moldova','Moldova' { a.Country_Code_EW__c = 'MD'; }
            when 'Muntenegru' { a.Country_Code_EW__c = 'ME'; }
            when 'Madagascar' { a.Country_Code_EW__c = 'MG'; }
            when 'Insulele Marshall' { a.Country_Code_EW__c = 'MH'; }
            when 'Mali' { a.Country_Code_EW__c = 'ML'; }
            when 'Myanmar' { a.Country_Code_EW__c = 'MM'; }
            when 'Mongolia' { a.Country_Code_EW__c = 'MN'; }
            when 'Macao' { a.Country_Code_EW__c = 'MO'; }
            when 'Insulele Mariane de Nord' { a.Country_Code_EW__c = 'MP'; }
            when 'Mauritania' { a.Country_Code_EW__c = 'MR'; }
            when 'Montserrat' { a.Country_Code_EW__c = 'MS'; }
            when 'Malta' { a.Country_Code_EW__c = 'MT'; }
            when 'Mauritius' { a.Country_Code_EW__c = 'MU'; }
            when 'Maldive' { a.Country_Code_EW__c = 'MV'; }
            when 'Malawi' { a.Country_Code_EW__c = 'MW'; }
            when 'Mexic' { a.Country_Code_EW__c = 'MX'; }
            when 'Malaysia' { a.Country_Code_EW__c = 'MY'; }
            when 'Mozambic' { a.Country_Code_EW__c = 'MZ'; }
            when 'Namibia' { a.Country_Code_EW__c = 'NA'; }
            when 'Noua Caledonie' { a.Country_Code_EW__c = 'NC'; }
            when 'Niger' { a.Country_Code_EW__c = 'NE'; }
            when 'Insula Norfolk' { a.Country_Code_EW__c = 'NF'; }
            when 'Nigeria' { a.Country_Code_EW__c = 'NG'; }
            when 'Nicaragua' { a.Country_Code_EW__c = 'NI'; }
            when 'Olanda' { a.Country_Code_EW__c = 'NL'; }
            when 'Norvegia' { a.Country_Code_EW__c = 'NO'; }
            when 'Nepal' { a.Country_Code_EW__c = 'NP'; }
            when 'Nauru' { a.Country_Code_EW__c = 'NR'; }
            when 'Niue' { a.Country_Code_EW__c = 'NU'; }
            when 'Noua Zeelandă' { a.Country_Code_EW__c = 'NZ'; }
            when 'Oman' { a.Country_Code_EW__c = 'OM'; }
            when 'Panama' { a.Country_Code_EW__c = 'PA'; }
            when 'Peru' { a.Country_Code_EW__c = 'PE'; }
            when 'Polinezia Franceză' { a.Country_Code_EW__c = 'PF'; }
            when 'PapuaNoua Guinee' { a.Country_Code_EW__c = 'PG'; }
            when 'Filipine' { a.Country_Code_EW__c = 'PH'; }
            when 'Pakistan' { a.Country_Code_EW__c = 'PK'; }
            when 'Polonia' { a.Country_Code_EW__c = 'PL'; }
            when 'Saint-Pierre şi Miquelon' { a.Country_Code_EW__c = 'PM'; }
            when 'Pitcairn' { a.Country_Code_EW__c = 'PN'; }
            when 'Teritoriul Palestinian Ocupat' { a.Country_Code_EW__c = 'PS'; }
            when 'Portugalia' { a.Country_Code_EW__c = 'PT'; }
            when 'Palau' { a.Country_Code_EW__c = 'PW'; }
            when 'Paraguay' { a.Country_Code_EW__c = 'PY'; }
            when 'Qatar' { a.Country_Code_EW__c = 'QA'; }
            when 'România', 'Romania' { a.Country_Code_EW__c = 'RO'; }
            when 'Federaţia Rusă' { a.Country_Code_EW__c = 'RU'; }
            when 'Rwanda' { a.Country_Code_EW__c = 'RW'; }
            when 'Arabia Saudită' { a.Country_Code_EW__c = 'SA'; }
            when 'Insulele Solomon' { a.Country_Code_EW__c = 'SB'; }
            when 'Seychelles' { a.Country_Code_EW__c = 'SC'; }
            when 'Sudan' { a.Country_Code_EW__c = 'SD'; }
            when 'Suedia' { a.Country_Code_EW__c = 'SE'; }
            when 'Singapore' { a.Country_Code_EW__c = 'SG'; }
            when 'Sfânta Elena, Ascension şi Tristan da Cunha' {
              a.Country_Code_EW__c = 'SH';
            }
            when 'Slovenia' { a.Country_Code_EW__c = 'SI'; }
            when 'Slovacia' { a.Country_Code_EW__c = 'SK'; }
            when 'Sierra Leone' { a.Country_Code_EW__c = 'SL'; }
            when 'San Marino' { a.Country_Code_EW__c = 'SM'; }
            when 'Senegal' { a.Country_Code_EW__c = 'SN'; }
            when 'Somalia' { a.Country_Code_EW__c = 'SO'; }
            when 'Suriname' { a.Country_Code_EW__c = 'SR'; }
            when 'Sudanul de Sud' { a.Country_Code_EW__c = 'SS'; }
            when 'São Tomé şi Principe' { a.Country_Code_EW__c = 'ST'; }
            when 'El Salvador' { a.Country_Code_EW__c = 'SV'; }
            when 'Sint-Maarten (partea neerlandeză)' {
              a.Country_Code_EW__c = 'SX';
            }
            when 'Republica Arabă Siriană' { a.Country_Code_EW__c = 'SY'; }
            when 'Swaziland' { a.Country_Code_EW__c = 'SZ'; }
            when 'Insulele Turks şi Caicos' { a.Country_Code_EW__c = 'TC'; }
            when 'Ciad' { a.Country_Code_EW__c = 'TD'; }
            when 'Teritoriile Australe şi Antarctice Franceze' {
              a.Country_Code_EW__c = 'TF';
            }
            when 'Togo' { a.Country_Code_EW__c = 'TG'; }
            when 'Thailanda' { a.Country_Code_EW__c = 'TH'; }
            when 'Tadjikistan' { a.Country_Code_EW__c = 'TJ'; }
            when 'Tokelau' { a.Country_Code_EW__c = 'TK'; }
            when 'Timorul de Est' { a.Country_Code_EW__c = 'TL'; }
            when 'Turkmenistan' { a.Country_Code_EW__c = 'TM'; }
            when 'Tunisia' { a.Country_Code_EW__c = 'TN'; }
            when 'Tonga' { a.Country_Code_EW__c = 'TO'; }
            when 'Turcia' { a.Country_Code_EW__c = 'TR'; }
            when 'Trinidad şi Tobago' { a.Country_Code_EW__c = 'TT'; }
            when 'Tuvalu' { a.Country_Code_EW__c = 'TV'; }
            when 'Taiwan' { a.Country_Code_EW__c = 'TW'; }
            when 'Republica Unită Tanzania' { a.Country_Code_EW__c = 'TZ'; }
            when 'Ucraina' { a.Country_Code_EW__c = 'UA'; }
            when 'Uganda' { a.Country_Code_EW__c = 'UG'; }
            when 'Insulele Minore Îndepărtate ale Statelor Unite ale Americii' {
              a.Country_Code_EW__c = 'UM';
            }
            when 'Statele Unite' { a.Country_Code_EW__c = 'US'; }
            when 'Uruguay' { a.Country_Code_EW__c = 'UY'; }
            when 'Uzbekistan' { a.Country_Code_EW__c = 'UZ'; }
            when 'Sfântul Scaun (Statul Cetăţii Vaticanului)' {
              a.Country_Code_EW__c = 'VA';
            }
            when 'Saint Vincent şi Grenadine' { a.Country_Code_EW__c = 'VC'; }
            when 'Republica Bolivariană a Venezuelei' {
              a.Country_Code_EW__c = 'VE';
            }
            when 'Insulele Virgine Britanice' { a.Country_Code_EW__c = 'VG'; }
            when 'Insulele Virgine Americane' { a.Country_Code_EW__c = 'VI'; }
            when 'Vietnam' { a.Country_Code_EW__c = 'VN'; }
            when 'Vanuatu' { a.Country_Code_EW__c = 'VU'; }
            when 'Wallis şi Futuna' { a.Country_Code_EW__c = 'WF'; }
            when 'Samoa' { a.Country_Code_EW__c = 'WS'; }
            when 'Ceuta' { a.Country_Code_EW__c = 'XC'; }
            when 'Kosovo' { a.Country_Code_EW__c = 'XK'; }
            when 'Melilla' { a.Country_Code_EW__c = 'XL'; }
            when 'Serbia' { a.Country_Code_EW__c = 'XS'; }
            when 'Yemen' { a.Country_Code_EW__c = 'YE'; }
            when 'Mayotte' { a.Country_Code_EW__c = 'YT'; }
            when 'Africa de Sud' { a.Country_Code_EW__c = 'ZA'; }
            when 'Zambia' { a.Country_Code_EW__c = 'ZM'; }
            when 'Zimbabwe' { a.Country_Code_EW__c = 'ZW'; }
            when else {
              a.Country_Code_EW__c = '';
            }
          }

        // a.Country_Code_EW__c = 'RO';
        accs.add(a);
      }
    }
    // if (Account.SObjectType.getDescribe().isAccessible() &&
    // Account.SObjectType.getDescribe().isUpdateable()){
    // //update accs;
    // }
  }
}