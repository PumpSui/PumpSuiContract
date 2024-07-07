module srcoin::srcoin {
    use sui::coin;
    use sui::url::new_unsafe_from_bytes;

    const DECIMALS: u8 = 0;
    // Please pay attention to configuring the CoinMetaData information, 
    // which is usually not changed after the contract is deployed.
    const SYMBOLS: vector<u8> = b"ProjectSymbol";
    const NAME: vector<u8> = b"CoinName";
    // Recommend to include a url for swap to a Supporter Ticket, 
    // https://pumpsui.com/swap/{project_record_id}.
    const DESCRIPTION: vector<u8> = b"";
    const ICON_URL: vector<u8> = b"https://";  // Coin Icon

    public struct SRCOIN has drop {}

    // ======== Functions =========
    fun init(otw: SRCOIN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<SRCOIN>(
            otw,
            DECIMALS,
            SYMBOLS, 
            NAME, 
            DESCRIPTION, 
            option::some(new_unsafe_from_bytes(ICON_URL)), 
            ctx
        );
        let sender = ctx.sender();
        transfer::public_transfer(treasury_cap, sender);
        transfer::public_transfer(metadata, sender);
    }
}

