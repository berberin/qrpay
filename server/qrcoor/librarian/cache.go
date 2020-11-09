package librarian

import (
	"github.com/patrickmn/go-cache"
	"qrcoor/config"
	"qrcoor/formation"
	"time"
)

var billCache *cache.Cache
var billSecretCache *cache.Cache

func initCache() {
	billCache = cache.New(time.Duration(config.GlobalConfig.CacheTimeMinutes)*time.Minute, time.Duration(config.GlobalConfig.CacheTimeMinutes)*time.Minute)
	billSecretCache = cache.New(time.Duration(config.GlobalConfig.CacheTimeMinutes)*time.Minute, time.Duration(config.GlobalConfig.CacheTimeMinutes)*time.Minute)
}

func AddBillToCache(bill formation.Bill) {
	billCache.Set(bill.ID, bill, cache.DefaultExpiration)
}

func RemoveBillFromCache(billID string) {
	billCache.Delete(billID)
}

func GetBillFromCache(billID string) (formation.Bill, bool) {
	tmp, found := billCache.Get(billID)
	if found {
		return tmp.(formation.Bill), found
	}
	return formation.Bill{}, found
}

func AddBillSecret(billID string, billSecret string) {
	billSecretCache.Set(billID, billSecret, cache.DefaultExpiration)
}

func GetBillSecret(billID string) (string, bool) {
	tmp, found := billSecretCache.Get(billID)
	return tmp.(string), found
}

// errors.New("cache: not found")
