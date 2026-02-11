trigger CountryIsoUpdate on Account (before insert, before update) {
    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            CountryIsoUpdateHandler.countryIsoHandler(trigger.new);
        }
    }
}