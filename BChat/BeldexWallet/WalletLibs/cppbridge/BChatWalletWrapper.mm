//
//  BChatWalletWrapper.m
//  bchat
//


#import <Foundation/Foundation.h>
#import "BChatWalletWrapper.h"
#import "BChatConfig.h"

using namespace std;

struct WalletListenerImpl: Wallet::WalletListener
{
    BeldexWalletListener *_listener = NULL;
    
    ~WalletListenerImpl()
    {
        _listener = NULL;
    }
    
    void moneySpent(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }
    
    void moneyReceived(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }
    
    void unconfirmedMoneyReceived(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }

    void newBlock(uint64_t height)
    {
        if (_listener && _listener.newBlockHandler) {
            _listener.newBlockHandler(height);
        }
    }

    void updated()
    {
        // not implemented
    }

    void refreshed()
    {
        if (_listener && _listener.refreshHandler) {
            _listener.refreshHandler();
        }
    }
    
    void registerListener(BeldexWalletListener *listener)
    {
        _listener = listener;
    }
};


#pragma mark - Data

@interface BChatWalletWrapper ()
{
    Wallet::Wallet* beldex_wallet;
    WalletListenerImpl* beldex_walletListener;
    Wallet::PendingTransaction* beldex_pendingTransaction;
}
@end

@implementation BChatWalletWrapper

- (instancetype)init {
    if (self = [super init]) {
        beldex_wallet = nullptr;
        beldex_walletListener = nullptr;
    }
    return self;
}

+ (BChatWalletWrapper *)init_beldex_wallet:(Wallet::Wallet *)beldex_wallet {
    //    auto stat = beldex_wallet->status();
    //
    //    if (stat.first != Wallet::Wallet::Status_Ok) return NULL;
    //#if DEBUG
    //    Wallet::WalletManagerFactory::setLogLevel(Wallet::WalletManagerFactory::LogLevel_Max);
    //#endif
    //    BChatWalletWrapper *walletWrapper = [[BChatWalletWrapper alloc] init];
    //    walletWrapper->beldex_wallet = beldex_wallet;
    //    cout<<"beldex_wallet<><> init_Wallet---->"<< &beldex_wallet<< endl;
    //    return walletWrapper;
    //
    if (beldex_wallet->status().first != Wallet::Wallet::Status_Ok) return NULL;
#if DEBUG
    Wallet::WalletManagerFactory::setLogLevel(Wallet::WalletManagerFactory::LogLevel_Max);
#endif
    
    BChatWalletWrapper *walletWrapper = [[BChatWalletWrapper alloc] init];
    walletWrapper->beldex_wallet = beldex_wallet;
    return walletWrapper;
}

+ (BChatWalletWrapper *)generateWithPath:(NSString *)path
                                 password:(NSString *)password
                                 language:(NSString *)language {
    struct Wallet::WalletManagerBase *walletManager = Wallet::WalletManagerFactory::getWalletManager();
    string utf8Path = [path UTF8String];
    string utf8Pwd = [password UTF8String];
    string utf8Lg = [language UTF8String];
    Wallet::Wallet* beldex_wallet = walletManager->createWallet(utf8Path, utf8Pwd, utf8Lg, netType);
    return [self init_beldex_wallet:beldex_wallet];
}

+ (BChatWalletWrapper *)recoverWithSeed:(NSString *)seed
                                    path:(NSString *)path
                                password:(NSString *)password {
    struct Wallet::WalletManagerBase *walletManager = Wallet::WalletManagerFactory::getWalletManager();
    string utf8Path = [path UTF8String];
    string utf8Pwd = [password UTF8String];
    string utf8Seed = [seed UTF8String];
    Wallet::Wallet* beldex_wallet = walletManager->recoveryWallet(utf8Path, utf8Pwd, utf8Seed, netType, 0, 1);
    return [self init_beldex_wallet:beldex_wallet];
}

+ (BChatWalletWrapper *)recoverFromKeysWithPath:(NSString *)path
                                        password:(NSString *)password
                                        language:(NSString *)language
                                   restoreHeight:(uint64_t)restoreHeight
                                         address:(NSString *)address
                                         viewKey:(NSString *)viewKey
                                        spendKey:(NSString *)spendKey {
    struct Wallet::WalletManagerBase *walletManager = Wallet::WalletManagerFactory::getWalletManager();
    string utf8Path = [path UTF8String];
    string utf8Pwd = [password UTF8String];
    string utf8Language = [language UTF8String];
    string utf8Address = [address UTF8String];
    string utf8ViewKey = [viewKey UTF8String];
    string utf8SpendKey = [spendKey UTF8String];
    Wallet::Wallet* beldex_wallet = walletManager->createWalletFromKeys(utf8Path, utf8Pwd, utf8Language, netType, restoreHeight, utf8Address, utf8ViewKey, utf8SpendKey);
    return [self init_beldex_wallet:beldex_wallet];
}

+ (BChatWalletWrapper *)openExistingWithPath:(NSString *)path
                                     password:(NSString *)password {
    struct Wallet::WalletManagerBase *walletManager = Wallet::WalletManagerFactory::getWalletManager();
    string utf8Path = [path UTF8String];
    string utf8Pwd = [password UTF8String];
    Wallet::Wallet* beldex_wallet = walletManager->openWallet(utf8Path, utf8Pwd, netType);
    return [self init_beldex_wallet:beldex_wallet];
}

#pragma mark ___listener

- (void)addListener {
    if (beldex_walletListener) return;
    WalletListenerImpl * impl = new WalletListenerImpl();
    beldex_wallet->setListener(impl);
    beldex_walletListener = impl;
}

- (void)setBlocksRefresh:(BeldexWalletRefreshHandler)refresh newBlock:(BeldexWalletNewBlockHandler)newBlock {
    [self addListener];
    beldex_walletListener->registerListener(NULL);
    BeldexWalletListener *listener = [[BeldexWalletListener alloc] init];
    listener.newBlockHandler = newBlock;
    listener.refreshHandler = refresh;
    beldex_walletListener->registerListener(listener);
}

- (void)setDelegate:(id<BeldexWalletDelegate>)delegate {
    __weak typeof(delegate) weakDelegate = delegate;
    __weak typeof(self) weakSelf = self;
    [self setBlocksRefresh:^{
        if (weakSelf && weakDelegate && [weakDelegate respondsToSelector:@selector(beldexWalletRefreshed:)]) {
            BChatWalletWrapper * wallet = weakSelf;
            [weakDelegate beldexWalletRefreshed:(wallet)];
        }
    } newBlock:^(uint64_t curreneight) {
        if (weakSelf && weakDelegate && [weakDelegate respondsToSelector:@selector(beldexWalletNewBlock:currentHeight:)]) {
            BChatWalletWrapper * wallet = weakSelf;
            [weakDelegate beldexWalletNewBlock:wallet currentHeight:curreneight];
        }
    }];
}

#pragma mark ___deinit

//-(void)dealloc {
//    if (beldex_walletListener) {
//        beldex_walletListener->registerListener(NULL);
//        delete beldex_walletListener;
//        beldex_walletListener = nullptr;
//    }
//}


#pragma mark - Data

- (BOOL)connectToDaemon:(NSString *)daemonAddress {
    if (!beldex_wallet) return NO;
    return beldex_wallet->init([daemonAddress UTF8String]);
}

- (BOOL)connectToDaemon:(NSString *)daemonAddress delegate:(id<BeldexWalletDelegate>)delegate {
    [self setDelegate:delegate];
    return [self connectToDaemon:daemonAddress];
}

- (BOOL)connectToDaemon:(NSString *)daemonAddress refresh:(BeldexWalletRefreshHandler)refresh newBlock:(BeldexWalletNewBlockHandler)newBlock {
    [self setBlocksRefresh:refresh newBlock:newBlock];
    return [self connectToDaemon:daemonAddress];
}

- (void)startRefresh {
    if (beldex_wallet) {
        beldex_wallet->startRefresh();
    }
}

- (void)pauseRefresh {
    if (beldex_wallet) {
        beldex_wallet->pauseRefresh();
    }
}

- (BOOL)save {
    if (beldex_wallet) {
        return beldex_wallet->store(beldex_wallet->path());
    }
    return NO;
}

- (BOOL)close {
    BOOL success = YES;
    if (beldex_wallet) {
        beldex_wallet->pauseRefresh();
        beldex_wallet->setListener(nullptr);
        struct Wallet::WalletManagerBase *walletManager = Wallet::WalletManagerFactory::getWalletManager();
        if (!walletManager->closeWallet(beldex_wallet)) {
            NSLog(@"close wallet fail: %@", [self errorMessage]);
            success = NO;
        }
    }
    return success;
}


#pragma mark - Utils

#pragma mark ___class

+ (BOOL)validAddress:(NSString *)address {
    return Wallet::Wallet::addressValid([address UTF8String], netType);
}

+ (BOOL)verifyPassword:(NSString *)password path:(NSString *)path {
    Wallet::Wallet::Device device_type;
    string utf8Path = [path UTF8String];
    string utf8Pwd = [password UTF8String];
    return Wallet::WalletManagerFactory::getWalletManager()->queryWalletDevice(device_type, utf8Path, utf8Pwd);
}

+ (NSString *)displayAmount:(uint64_t)amount {
    string amountStr = Wallet::Wallet::displayAmount(amount);
    return objc_str_dup(amountStr);
}

+ (NSString *)generatePaymentId {
    string payment_id = Wallet::Wallet::genPaymentId();
    return objc_str_dup(payment_id);
}

+ (NSString *)paymentIdFromAddress:(NSString *)address {
    string utf8Address = [address UTF8String];
    string payment_id = Wallet::Wallet::paymentIdFromAddress(utf8Address, netType);
    return objc_str_dup(payment_id);
}


#pragma mark ___object

- (NSString *)getSeedString:(NSString *)language {
    string seed = "";
    if (beldex_wallet) {
        beldex_wallet->setSeedLanguage([language UTF8String]);
        seed = beldex_wallet->seed();
    }
    return objc_str_dup(seed);
}

- (BOOL)setNewPassword:(NSString *)password {
    if (beldex_wallet) {
        return beldex_wallet->setPassword([password UTF8String]);
    }
    return NO;
}

- (NSString *)generateIntegartedAddress:(NSString *)paymentId {
    string integratedAddress = "";
    if (beldex_wallet) {
        integratedAddress = beldex_wallet->integratedAddress([paymentId UTF8String]);
    }
    return objc_str_dup(integratedAddress);
}


#pragma mark - SubAddress

- (BOOL)addSubAddress:(NSString *)label accountIndex:(uint32_t)index {
    if (beldex_wallet) {
        beldex_wallet->addSubaddress(index, [label UTF8String]);
        return YES;
    }
    return NO;
}

- (BOOL)setSubAddress:(NSString *)label addressIndex:(uint32_t)addressIndex accountIndex:(uint32_t)accountIndex {
    if (beldex_wallet) {
        beldex_wallet->setSubaddressLabel(accountIndex, addressIndex, [label UTF8String]);
        return YES;
    }
    return NO;
}

- (NSArray<BeldexSubAddress *> *)fetchSubAddressWithAccountIndex:(uint32_t)index {
    NSMutableArray<BeldexSubAddress *> *result = [NSMutableArray array];
    if (beldex_wallet) {
        Wallet::Subaddress * subAddress = beldex_wallet->subaddress();
        if (subAddress) {
            subAddress->refresh(index);
            std::vector<Wallet::SubaddressRow *> all = subAddress->getAll();
            std::size_t allCount = all.size();
            for (std::size_t i = 0; i < allCount; ++i) {
                Wallet::SubaddressRow *item = all[i];
                [result addObject:[[BeldexSubAddress alloc] initWithRowId:item->getRowId()
                                                                  address:objc_str_dup(item->getAddress())
                                                                    label:objc_str_dup(item->getLabel())]];
            }
        }
    }
    return result;
}


#pragma mark - Transaction

- (BOOL)createTransactionToAddress:(NSString *)address paymentId:(NSString *)paymentId amount:(NSString *)amount mixinCount:(uint32_t)mixinCount priority:(PendingTransactionPriority)priority {
    if (!beldex_wallet) return NO;
    [self disposeTransaction];
    optional<uint64_t> _amount;
    if (![amount isEqualToString:@"sweep"]) {
        _amount = Wallet::Wallet::amountFromString([amount UTF8String]);
    }
    beldex_pendingTransaction = beldex_wallet->createTransaction([address UTF8String],
                                                                 _amount,
                                                                 (Wallet::PendingTransaction::Priority)priority);
    if (!beldex_pendingTransaction) return NO;
    if (beldex_pendingTransaction->status().first != Status_Ok) {
        NSLog(@"monero createTransaction fail reason: %@", [self transactionErrorMessage]);
        return NO;
    }
    return YES;
}

//- (BOOL)createTransactionToAddress:(NSString *)address paymentId:(NSString *)paymentId amount:(NSString *)amount mixinCount:(uint32_t)mixinCount priority:(PendingTransactionPriority)priority {
//    if (!beldex_wallet) return NO;
//    [self disposeTransaction];
//    std::optional<uint64_t> _amount;
//    if (![amount isEqualToString:@"sweep"]) {
//        _amount = Wallet::Wallet::amountFromString([amount UTF8String]);
//    }
//    beldex_pendingTransaction = beldex_wallet->createTransaction([address UTF8String],
//                                                                 _amount,
//                                                                 mixinCount,
//                                                                 (Wallet::PendingTransaction::Priority)priority);
//    if (!beldex_pendingTransaction) return NO;
////    NSLog(@"Status_Ok------------->: %u",Status_Ok);
////    NSLog(@"beldex_pendingTransaction----->: %d", beldex_pendingTransaction->status().first);
//    if (beldex_pendingTransaction->status().first != Status_Ok) {
//        NSLog(@"beldex createTransaction fail reason: %@", [self transactionErrorMessage]);
//        return NO;
//    }
//    return YES;
//}

- (BOOL)createSweepTransactionToAddress:(NSString *)address paymentId:(NSString *)paymentId mixinCount:(uint32_t)mixinCount priority:(PendingTransactionPriority)priority {
    return [self createTransactionToAddress:address paymentId:paymentId amount:@"sweep" mixinCount:mixinCount priority:priority];
}

- (BOOL)commitPendingTransaction {
    if (beldex_pendingTransaction) {
        return beldex_pendingTransaction->commit();
    }
    return NO;
}

- (void)disposeTransaction {
    if (beldex_wallet && beldex_pendingTransaction) {
        beldex_wallet->disposeTransaction(beldex_pendingTransaction);
        beldex_pendingTransaction = NULL;
    }
}

- (int64_t)transactionFee {
    if (beldex_pendingTransaction) {
        return beldex_pendingTransaction->fee();
    }
    return -1;
}

- (NSString *)transactionHash {
    string errorStr = "";
    if (beldex_pendingTransaction) {
        std::vector<std::string> all = beldex_pendingTransaction->txid();
        return objc_str_dup(all.front().c_str());
    }
    return objc_str_dup(errorStr);
}

- (NSString *)transactionErrorMessage {
    string errorStr = "";
    if (beldex_pendingTransaction) {
        errorStr = beldex_pendingTransaction->status().second;
    }
    return objc_str_dup(errorStr);
}

- (NSArray<BeldexTrxHistory *> *)fetchTransactionHistory {
    NSMutableArray<BeldexTrxHistory *> *result = [NSMutableArray array];
    if (beldex_wallet) {
        Wallet::TransactionHistory *history = beldex_wallet->history();
        if (history) {
            history->refresh();
            std::vector<Wallet::TransactionInfo *> allTransactionInfo = history->getAll();
            for (std::size_t i = 0; i < history->count(); ++i) {
                Wallet::TransactionInfo *transactionInfo = allTransactionInfo[i];
                BeldexTrxHistory * trx = [[BeldexTrxHistory alloc] init];
                trx.direction = (TrxDirection)transactionInfo->direction();
                trx.isPending = transactionInfo->isPending();
                trx.isFailed = transactionInfo->isFailed();
                trx.amount = transactionInfo->amount();
                trx.fee = transactionInfo->fee();
                trx.confirmations = transactionInfo->confirmations();
                trx.timestamp = transactionInfo->timestamp();
                trx.blockHeight = transactionInfo->blockHeight();
                trx.hashValue = objc_str_dup(transactionInfo->hash());
                trx.label = objc_str_dup(transactionInfo->label());
                trx.paymentId = objc_str_dup(transactionInfo->paymentId());
                trx.unlockTime = transactionInfo->unlockTime();
                [result addObject:trx];
            }
        }
    }
    return result;
}


#pragma mark - Properties

#pragma mark ___setter

- (void)setRestoreHeight:(uint64_t)restoreHeight {
    if (beldex_wallet) {
        beldex_wallet->setRefreshFromBlockHeight(restoreHeight);
    }
}

#pragma mark ___getter

- (NSString *)name {
    NSString *name = @"";
    if (beldex_wallet) {
        NSString *filename = objc_str_dup(beldex_wallet->filename());
        NSString *lastItem = [[filename componentsSeparatedByString:@"/"] lastObject];
        if (lastItem) {
            name = lastItem;
        }
    }
    return name;
}

- (BOOL)isSynchronized {
    if (!beldex_wallet) return NO;
    return beldex_wallet->synchronized();
}

- (int)status {
    if (!beldex_wallet) return 0;
    return beldex_wallet->status().first;
}

- (NSString *)errorMessage {
    string errorString = "";
    if (beldex_wallet) {
        errorString = beldex_wallet->status().second;
    }
    return objc_str_dup(errorString);
}

- (NSString *)publicViewKey {
    string key  = "";
    if (beldex_wallet) {
        key = beldex_wallet->publicViewKey();
    }
    return objc_str_dup(key);
}

- (NSString *)publicSpendKey {
    string key  = "";
    if (beldex_wallet) {
        key = beldex_wallet->publicSpendKey();
    }
    return objc_str_dup(key);
}

- (NSString *)secretViewKey {
    string key  = "";
    if (beldex_wallet) {
        key = beldex_wallet->secretViewKey();
    }
    return objc_str_dup(key);
}

- (NSString *)secretSpendKey {
    string key  = "";
    if (beldex_wallet) {
        key = beldex_wallet->secretSpendKey();
    }
    return objc_str_dup(key);
}

- (NSString *)publicAddress {
    string address  = "";
    if (beldex_wallet) {
        address = beldex_wallet->address();
    }
    return objc_str_dup(address);
}

- (uint64_t)balance {
    if (beldex_wallet) {
        return beldex_wallet->balance();
    }
    return 0;
}

- (uint64_t)unlockedBalance {
    if (beldex_wallet) {
        return beldex_wallet->unlockedBalance();
    }
    return 0;
}

- (uint64_t)blockChainHeight {
    if (beldex_wallet) {
        return beldex_wallet->blockChainHeight();
    }
    return 0;
}

- (uint64_t)daemonBlockChainHeight {
    if (beldex_wallet) {
        return beldex_wallet->daemonBlockChainHeight();
    }
    return 0;
}

- (uint64_t)restoreHeight {
    if (beldex_wallet) {
        return beldex_wallet->getRefreshFromBlockHeight();
    }
    return 0;
}


@end
