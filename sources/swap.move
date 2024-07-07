module suifund::swap {
    use std::type_name;
    use sui::coin::{Self, Coin, CoinMetadata, TreasuryCap};
    use suifund::suifund::{Self, ProjectRecord, ProjectAdminCap, SupporterReward};

    const COIN_TYPE: vector<u8> = b"coin_type";
    const TREASURY: vector<u8> = b"treasury";
    const METADATA: vector<u8> = b"metadata";
    const STORAGE: vector<u8> = b"storage_sr";

    const EAlreadyInit: u64 = 0;
    const EInvalidMetaData: u64 = 1;
    const EInvalidTreasuryCap: u64 = 2;
    const ENotInit: u64 = 3;
    const ENotSameProject: u64 = 4;
    const EZeroCoin: u64 = 5;

    public entry fun init_swap<T>(
        project_record: &mut ProjectRecord,
        project_admin_cap: &ProjectAdminCap,
        treasury_cap: TreasuryCap<T>,
        coin_metadata: CoinMetadata<T>,
    ) {
        assert!(!suifund::exists_in_project<std::ascii::String>(project_record, std::ascii::string(COIN_TYPE)), EAlreadyInit);
        suifund::check_project_cap(project_record, project_admin_cap);
        assert!(coin::get_decimals<T>(&coin_metadata) == 0, EInvalidMetaData);
        assert!(coin::total_supply<T>(&treasury_cap) == 0, EInvalidTreasuryCap);

        let coin_type = type_name::into_string(type_name::get_with_original_ids<T>());
        suifund::add_df_in_project<std::ascii::String, std::ascii::String>(project_record, std::ascii::string(COIN_TYPE), coin_type);
        suifund::add_df_in_project<std::ascii::String, TreasuryCap<T>>(project_record, std::ascii::string(TREASURY), treasury_cap);
        suifund::add_df_in_project<std::ascii::String, CoinMetadata<T>>(project_record, std::ascii::string(METADATA), coin_metadata);
        suifund::add_df_in_project<std::ascii::String, vector<SupporterReward>>(project_record, std::ascii::string(STORAGE), vector::empty<SupporterReward>());
    }

    public fun sr_to_coin<T>(
        project_record: &mut ProjectRecord,
        supporter_reward: SupporterReward,
        ctx: &mut TxContext
    ): Coin<T> {
        assert!(suifund::exists_in_project<std::ascii::String>(project_record, std::ascii::string(COIN_TYPE)), ENotInit);
        assert!(suifund::project_name(project_record) == suifund::sr_name(&supporter_reward), ENotSameProject);
        let value = suifund::sr_amount(&supporter_reward);
        let storage_sr = suifund::borrow_mut_in_project<std::ascii::String, vector<SupporterReward>>(project_record, std::ascii::string(STORAGE));

        if (vector::is_empty<SupporterReward>(storage_sr)) {
            vector::push_back<SupporterReward>(storage_sr, supporter_reward);
        } else {
            let sr_mut = vector::borrow_mut<SupporterReward>(storage_sr, 0);
            suifund::do_merge(sr_mut, supporter_reward);
        };

        let treasury = suifund::borrow_mut_in_project<std::ascii::String, TreasuryCap<T>>(project_record, std::ascii::string(TREASURY));
        coin::mint<T>(treasury, value, ctx)
    }

    public entry fun sr_to_coin_swap<T>(
        project_record: &mut ProjectRecord,
        supporter_reward: SupporterReward,
        ctx: &mut TxContext
    ) {
        let coin = sr_to_coin<T>(project_record, supporter_reward, ctx);
        transfer::public_transfer(coin, ctx.sender());
    }

    public fun coin_to_sr<T>(
        project_record: &mut ProjectRecord,
        sr_coin: Coin<T>,
        ctx: &mut TxContext
    ): SupporterReward {
        assert!(suifund::exists_in_project<std::ascii::String>(project_record, std::ascii::string(COIN_TYPE)), ENotInit);
        let treasury = suifund::borrow_mut_in_project<std::ascii::String, TreasuryCap<T>>(project_record, std::ascii::string(TREASURY));
        let value = coin::burn<T>(treasury, sr_coin);
        assert!(value > 0, EZeroCoin);

        let storage_sr = suifund::borrow_mut_in_project<std::ascii::String, vector<SupporterReward>>(project_record, std::ascii::string(STORAGE));
        let sr_b = vector::borrow<SupporterReward>(storage_sr, 0);
        let sr_tsv = suifund::sr_amount(sr_b);

        if (sr_tsv == value) {
            vector::pop_back<SupporterReward>(storage_sr)
        } else {
            let sr_bm = vector::borrow_mut<SupporterReward>(storage_sr, 0);
            suifund::do_split(sr_bm, value, ctx)
        }
    }

    public entry fun coin_to_sr_swap<T>(
        project_record: &mut ProjectRecord,
        sr_coin: Coin<T>,
        ctx: &mut TxContext
    ) {
        let sr = coin_to_sr<T>(project_record, sr_coin, ctx);
        transfer::public_transfer(sr, ctx.sender());
    }

    // ======== Edit Functions =========


    // ======== Read Functions =========
    public fun get_decimals(): u8 {
        0
    }

    public fun get_coin_type(project_record: &ProjectRecord): &std::ascii::String {
        suifund::borrow_in_project<std::ascii::String, std::ascii::String>(project_record, std::ascii::string(COIN_TYPE))
    }

    public fun get_total_supply<T>(project_record: &ProjectRecord): u64 {
        let treasury = suifund::borrow_in_project<std::ascii::String, TreasuryCap<T>>(project_record, std::ascii::string(TREASURY));
        coin::total_supply<T>(treasury)
    }
}