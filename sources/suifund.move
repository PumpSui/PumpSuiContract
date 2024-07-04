module suifund::suifund {
    use std::type_name;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::table::{Self, Table};
    use sui::table_vec::{Self, TableVec};
    use sui::event::emit;
    use sui::sui::SUI;
    use sui::package;
    use sui::display;
    use sui::url::{Self, Url};
    use sui::clock::{Self, Clock};
    use sui::dynamic_field as df;
    use sui_system::staking_pool::StakedSui;
    use sui_system::sui_system::{request_add_stake_non_entry, SuiSystemState, request_withdraw_stake_non_entry};
    use suifund::comment::{Self, Comment};
    use suifund::utils::{mul_div, get_remain_value};
    use suifund::svg::generateSVG;

    // ======== Constants =========
    const VERSION: u64 = 1;
    const THREE_DAYS_IN_MS: u64 = 259_200_000;
    const SUI_BASE: u64 = 1_000_000_000;
    const BASE_FEE: u64 = 20_000_000_000; // 20 SUI

    // ======== Errors =========
    const EInvalidStartTime: u64 = 1;
    const EInvalidTimeInterval: u64 = 2;
    const EInvalidRatio: u64 = 3;
    const EInvalidSuiValue: u64 = 4;
    const ETooLittle: u64 = 5;
    const ENotStarted: u64 = 6;
    const EEnded: u64 = 7;
    const ECapMismatch: u64 = 8;
    const EAlreadyMax: u64 = 9;
    const ENotSameProject: u64 = 10;
    const ErrorAttachDFExists: u64 = 11;
    const EInvalidAmount: u64 = 12;
    const ENotSplitable: u64 = 13;
    const EProjectCanceled: u64 = 14;
    const ENotBurnable: u64 = 15;
    const EVersionMismatch: u64 = 16;
    const EImproperRatio: u64 = 17;
    const EProjectNotCanceled: u64 = 18;
    const ETakeAwayNotCompleted: u64 = 19;

    // ======== Types =========
    public struct SUIFUND has drop {}

    public struct DeployRecord has key {
        id: UID,
        version: u64,
        record: Table<std::ascii::String, ID>,
        balance: Balance<SUI>,
        base_fee: u64,
        ratio: u64,
    }

    public struct ProjectRecord has key {
        id: UID,
        version: u64,
        creator: address,
        name: std::ascii::String,
        description: std::string::String,
        image_url: Url,
        x: Url,
        telegram: Url,
        discord: Url,
        website: Url,
        github: Url,
        cancel: bool,
        balance: Balance<SUI>,
        ratio: u64,
        start_time_ms: u64,
        end_time_ms: u64,
        total_supply: u64,
        amount_per_sui: u64, 
        remain: u64,
        current_supply: u64,
        total_transactions: u64,
        min_value_sui: u64, 
        max_value_sui: u64,
        participants: TableVec<address>, 
        minted_per_user: Table<address, u64>,
        thread: TableVec<Comment>,
    }

    public struct ProjectAdminCap has key, store {
        id: UID,
        to: ID,
    }

    public struct AdminCap has key, store {
        id: UID,
    }

    public struct SupporterReward has key, store {
        id: UID,
        name: std::ascii::String,
        image_url: Url,
        amount: u64,
        balance: Balance<SUI>,
        start: u64,
        end: u64,
        attach_df: u8,
    }

    // ======== Events =========
    public struct DeployEvent has copy, drop {
        project_id: ID,
        project_name: std::ascii::String,
        deployer: address,
        deploy_fee: u64,
    }

    public struct EditProject has copy, drop {
        project_name: std::ascii::String,
        editor: address,
    }

    public struct MintEvent has copy, drop {
        project_name: std::ascii::String,
        sender: address,
        amount: u64,
    }

    public struct BurnEvent has copy, drop {
        project_name: std::ascii::String,
        sender: address,
        amount: u64,
        withdraw_value: u64,
        inside_value: u64,
    }

    public struct ReferenceReward has copy, drop {
        sender: address,
        recipient: address,
        value: u64,
    }

    public struct ClaimStreamPayment has copy, drop {
        project_name: std::ascii::String,
        sender: address,
        value: u64,
    }


    // ======== Functions =========
    fun init(otw: SUIFUND, ctx: &mut TxContext) {
        let deployer = ctx.sender();
        let deploy_record = DeployRecord { id: object::new(ctx), version: VERSION, record: table::new(ctx), balance: balance::zero<SUI>(), base_fee: BASE_FEE, ratio: 1 };
        transfer::share_object(deploy_record);
        let admin_cap = AdminCap { id: object::new(ctx) };
        transfer::public_transfer(admin_cap, deployer);

        let keys = vector[
            std::string::utf8(b"name"),
            std::string::utf8(b"image_url"),
            std::string::utf8(b"project_url"),
            std::string::utf8(b"start"),
            std::string::utf8(b"end"),
            std::string::utf8(b"alert!"),
        ];
        let background_url = b"{image_url}";
        let project_name = b"{name}";
        let amount = b"{amount}";
        let image_url = generateSVG(background_url, project_name, amount);
        let values = vector[
            std::string::utf8(b"Supporter Ticket"),
            std::string::utf8(image_url),
            std::string::utf8(b""),
            std::string::utf8(b"{start}"),
            std::string::utf8(b"{end}"),
            std::string::utf8(b"Do not visit any links in the pictures, as they may be scams."),
        ];

        let publisher = package::claim(otw, ctx);
        let mut display = display::new_with_fields<SupporterReward>(
            &publisher, keys, values, ctx
        );
        display::update_version(&mut display);
        transfer::public_transfer(publisher, deployer);
        transfer::public_transfer(display, deployer);
    }

    // ======= Deploy functions ========

    public fun get_deploy_fee(
        total_deposit_sui: u64,
        base_fee: u64,
        project_ratio: u64,
        deploy_ratio: u64
    ): u64 {
        assert!(deploy_ratio <= 5, EImproperRatio);
        let cal_value: u64 = total_deposit_sui * project_ratio * deploy_ratio / 10000;
        let fee_value: u64 =  if (cal_value > base_fee) {
            cal_value
        } else { base_fee };
        fee_value
    }

    public entry fun deploy(
        deploy_record: &mut DeployRecord,
        name: vector<u8>,
        description: vector<u8>,
        image_url: vector<u8>,
        x: vector<u8>,
        telegram: vector<u8>,
        discord: vector<u8>,
        website: vector<u8>,
        github: vector<u8>,
        start_time_ms: u64,
        time_interval: u64,
        total_deposit_sui: u64,
        ratio: u64,
        amount_per_sui: u64,
        min_value_sui: u64, 
        max_value_sui: u64,
        fee: &mut Coin<SUI>,
        clk: &Clock,
        ctx: &mut TxContext
    ) {
        let project_admin_cap = deploy_non_entry(
            deploy_record,
            name,
            description,
            image_url,
            x,
            telegram,
            discord,
            website,
            github,
            start_time_ms,
            time_interval,
            total_deposit_sui,
            ratio,
            amount_per_sui,
            min_value_sui, 
            max_value_sui,
            fee,
            clk,
            ctx
        );
        transfer::public_transfer(project_admin_cap, ctx.sender());
    }

    public fun deploy_non_entry(
        deploy_record: &mut DeployRecord,
        name: vector<u8>,
        description: vector<u8>,
        image_url: vector<u8>,
        x: vector<u8>,
        telegram: vector<u8>,
        discord: vector<u8>,
        website: vector<u8>,
        github: vector<u8>,
        start_time_ms: u64,
        time_interval: u64,
        total_deposit_sui: u64,
        ratio: u64,
        amount_per_sui: u64,
        min_value_sui: u64, 
        max_value_sui: u64,
        fee: &mut Coin<SUI>,
        clk: &Clock,
        ctx: &mut TxContext
    ): ProjectAdminCap {
        assert!(deploy_record.version == VERSION, EVersionMismatch);
        let sender = ctx.sender();
        let now = clock::timestamp_ms(clk);
        assert!(start_time_ms >= now, EInvalidStartTime);
        assert!(time_interval >= THREE_DAYS_IN_MS, EInvalidTimeInterval);
        assert!(ratio <= 100, EInvalidRatio);
        assert!(min_value_sui >= SUI_BASE, ETooLittle);
        if (max_value_sui != 0) {
            assert!(min_value_sui <= max_value_sui, EInvalidSuiValue);
        };

        let deploy_fee = get_deploy_fee(total_deposit_sui, deploy_record.base_fee, ratio, deploy_record.ratio);
        let deploy_coin = coin::split<SUI>(fee, deploy_fee, ctx);
        balance::join<SUI>(&mut deploy_record.balance, coin::into_balance<SUI>(deploy_coin));

        let total_supply = total_deposit_sui / SUI_BASE * amount_per_sui;
        let project_name = std::ascii::string(name); 
        let project_record = ProjectRecord {
            id: object::new(ctx),
            version: VERSION,
            creator: sender,
            name: project_name,
            description: std::string::utf8(description),
            image_url: url::new_unsafe_from_bytes(image_url),
            x: url::new_unsafe_from_bytes(x),
            telegram: url::new_unsafe_from_bytes(telegram),
            discord: url::new_unsafe_from_bytes(discord),
            website: url::new_unsafe_from_bytes(website),
            github: url::new_unsafe_from_bytes(github),
            cancel: false,
            balance: balance::zero<SUI>(),
            ratio,
            start_time_ms,
            end_time_ms: start_time_ms + time_interval,
            total_supply,
            amount_per_sui,
            remain: total_supply,
            current_supply: 0,
            total_transactions: 0,
            min_value_sui,
            max_value_sui,
            participants: table_vec::empty<address>(ctx),
            minted_per_user: table::new<address, u64>(ctx),
            thread: table_vec::empty<Comment>(ctx),
        };

        let project_id = object::id(&project_record);
        let project_admin_cap = ProjectAdminCap {
            id: object::new(ctx),
            to: project_id,
        };

        table::add<std::ascii::String, ID>(&mut deploy_record.record, project_name, project_id);

        transfer::share_object(project_record);
        emit(DeployEvent {
            project_id,
            project_name,
            deployer: sender,
            deploy_fee,
        });

        project_admin_cap
    }

    // ======= Claim functions ========

    public fun do_claim(
        project_record: &mut ProjectRecord,
        project_admin_cap: &ProjectAdminCap,
        clk: &Clock,
        ctx: &mut TxContext
    ): Coin<SUI> {
        assert!(project_record.version == VERSION, EVersionMismatch);
        check_project_cap(project_record, project_admin_cap);
        assert!(!project_record.cancel, EProjectCanceled);

        let now = clock::timestamp_ms(clk);
        let mut init_value = mul_div(project_record.current_supply, SUI_BASE, project_record.amount_per_sui);
        init_value = init_value * project_record.ratio / 100;
        let remain_value = get_remain_value(init_value, project_record.start_time_ms, project_record.end_time_ms, now);
        let claim_value = balance::value<SUI>(&project_record.balance) - remain_value;

        emit(ClaimStreamPayment {
            project_name: project_record.name,
            sender: ctx.sender(),
            value: claim_value,
        });

        coin::take<SUI>(&mut project_record.balance, claim_value, ctx)
    }

    public entry fun claim(
        project_record: &mut ProjectRecord,
        project_admin_cap: &ProjectAdminCap,
        clk: &Clock,
        ctx: &mut TxContext
    ) {
        let claim_coin = do_claim(project_record, project_admin_cap, clk, ctx);
        transfer::public_transfer(claim_coin, ctx.sender());
    }

    // ======= Mint functions ========

    public entry fun mint(
        project_record: &mut ProjectRecord,
        fee_sui: &mut Coin<SUI>,
        clk: &Clock,
        ctx: &mut TxContext
    ) {
        let supporter_reward = do_mint(project_record, fee_sui, clk, ctx);
        transfer::public_transfer(supporter_reward, ctx.sender());
    }

    public fun do_mint(
        project_record: &mut ProjectRecord,
        fee_sui: &mut Coin<SUI>,
        clk: &Clock,
        ctx: &mut TxContext
    ): SupporterReward {
        let sender = ctx.sender();
        let now = clock::timestamp_ms(clk);
        assert!(now >= project_record.start_time_ms, ENotStarted);
        assert!(now <= project_record.end_time_ms, EEnded);
        assert!(project_record.version == VERSION, EVersionMismatch);
        assert!(!project_record.cancel, EProjectCanceled);

        let mut sui_value = coin::value(fee_sui);
        assert!(sui_value >= project_record.min_value_sui, ETooLittle);

        if (table::contains<address, u64>(&project_record.minted_per_user, sender)) {
            let minted_value = table::borrow_mut<address, u64>(&mut project_record.minted_per_user, sender);
            if (project_record.max_value_sui > 0 && sui_value + *minted_value > project_record.max_value_sui) {
                sui_value = project_record.max_value_sui - *minted_value;
            };
            assert!(sui_value > 0, EAlreadyMax);
            *minted_value = *minted_value + sui_value;
        } else {
            if (project_record.max_value_sui > 0 && sui_value > project_record.max_value_sui) {
                sui_value = project_record.max_value_sui;
            };
            table::add<address, u64>(&mut project_record.minted_per_user, sender, sui_value);
            table_vec::push_back<address>(&mut project_record.participants, sender);
        };

        let mut amount: u64 = mul_div(sui_value, project_record.amount_per_sui, SUI_BASE);

        if (amount >= project_record.remain) {
            amount = project_record.remain;
            sui_value = mul_div(amount, SUI_BASE, project_record.amount_per_sui);
        };

        project_record.remain = project_record.remain - amount;
        project_record.current_supply = project_record.current_supply + amount;
        project_record.total_transactions = project_record.total_transactions + 1;

        let project_sui_value = sui_value * project_record.ratio / 100;
        let locked_sui_value = sui_value * (100 - project_record.ratio) / 100;

        let project_sui = coin::into_balance<SUI>(coin::split<SUI>(fee_sui, project_sui_value, ctx));
        balance::join<SUI>(&mut project_record.balance, project_sui);

        emit(MintEvent {
            project_name: project_record.name,
            sender,
            amount,
        });

        let locked_sui = coin::into_balance<SUI>(coin::split<SUI>(fee_sui, locked_sui_value, ctx));
        new_supporter_reward(
            project_record.name,
            project_record.image_url,
            amount,
            locked_sui,
            project_record.start_time_ms,
            project_record.end_time_ms,
            ctx
        )
    }

    public fun reference_reward(reward: Coin<SUI>, sender: address, recipient: address) {
        emit(ReferenceReward {
            sender,
            recipient,
            value: coin::value<SUI>(&reward),
        });
        transfer::public_transfer(reward, recipient);
    }

    // ======= Merge functions ========

    public fun do_merge(
        sp_rwd_1: &mut SupporterReward,
        sp_rwd_2: SupporterReward
    ) {
        assert!(sp_rwd_1.name == sp_rwd_2.name, ENotSameProject);
        assert!(sp_rwd_2.attach_df == 0, ErrorAttachDFExists);
        
        let SupporterReward { id, name: _, image_url: _, amount, balance, start: _, end: _, attach_df: _ } = sp_rwd_2;
        sp_rwd_1.amount = sp_rwd_1.amount + amount;
        balance::join<SUI>(&mut sp_rwd_1.balance, balance);
        object::delete(id);
    }

    public entry fun merge(
        sp_rwd_1: &mut SupporterReward,
        sp_rwd_2: SupporterReward
    ) {
        do_merge(sp_rwd_1, sp_rwd_2);
    }

    // ======= Split functions ========

    public fun is_splitable(sp_rwd: &SupporterReward): bool {
        sp_rwd.amount > 1 && sp_rwd.attach_df == 0
    }

    public fun do_split(
        sp_rwd: &mut SupporterReward,
        amount: u64,
        ctx: &mut TxContext
    ): SupporterReward {
        assert!(0 < amount && amount < sp_rwd.amount, EInvalidAmount);
        assert!(is_splitable(sp_rwd), ENotSplitable);

        let sui_value = balance::value<SUI>(&sp_rwd.balance);

        let mut new_sui_value = mul_div(sui_value, amount, sp_rwd.amount);
        if (new_sui_value == 0) {
            new_sui_value = 1;
        };

        let new_sui_balance = balance::split<SUI>(&mut sp_rwd.balance, new_sui_value);
        sp_rwd.amount = sp_rwd.amount - amount;

        new_supporter_reward(
            sp_rwd.name,
            sp_rwd.image_url,
            amount,
            new_sui_balance,
            sp_rwd.start,
            sp_rwd.end,
            ctx
        )
    }

    public entry fun split(
        sp_rwd: &mut SupporterReward,
        amount: u64,
        ctx: &mut TxContext
    ) {
        let new_sp_rwd = do_split(sp_rwd, amount, ctx);
        transfer::public_transfer(new_sp_rwd, ctx.sender());
    }

    // ======= Burn functions ========

    public fun do_burn(
        project_record: &mut ProjectRecord,
        sp_rwd: SupporterReward,
        clk: &Clock,
        ctx: &mut TxContext
    ): Coin<SUI> {
        assert!(project_record.name == sp_rwd.name, ENotSameProject);
        assert!(project_record.version == VERSION, EVersionMismatch);
        assert!(sp_rwd.attach_df == 0, ENotBurnable);

        let sender = ctx.sender();
        let now = clock::timestamp_ms(clk);

        let total_value = if (project_record.cancel) {
            balance::value<SUI>(&project_record.balance)
        } else {
            get_remain_value(
                mul_div(project_record.current_supply, SUI_BASE, project_record.amount_per_sui),
                project_record.start_time_ms, 
                project_record.end_time_ms, 
                now
            ) * project_record.ratio / 100
        };

        let withdraw_value = mul_div(total_value, sp_rwd.amount, project_record.current_supply);
        let inside_value = balance::value<SUI>(&sp_rwd.balance);

        project_record.current_supply = project_record.current_supply - sp_rwd.amount;

        let SupporterReward {
            id,
            name,
            image_url: _,
            amount,
            balance,
            start: _,
            end: _,
            attach_df: _
        } = sp_rwd;

        let withdraw_balance: Balance<SUI> = balance::split<SUI>(&mut project_record.balance, withdraw_value);
        let mut withdraw_coin: Coin<SUI> = coin::from_balance<SUI>(withdraw_balance, ctx);
        let inside_coin: Coin<SUI> = coin::from_balance<SUI>(balance, ctx);
        coin::join<SUI>(&mut withdraw_coin, inside_coin);

        object::delete(id);

        emit(BurnEvent {
            project_name: name,
            sender,
            amount,
            withdraw_value,
            inside_value,
        });

        withdraw_coin
    }

    public entry fun burn(
        project_record: &mut ProjectRecord,
        sp_rwd: SupporterReward,
        clk: &Clock,
        ctx: &mut TxContext
    ) {
        let withdraw_coin = do_burn(project_record, sp_rwd, clk, ctx);
        transfer::public_transfer(withdraw_coin, ctx.sender());
    }

    // ======= Native Stake functions ========

    public entry fun native_stake(
        wrapper: &mut SuiSystemState,
        validator_address: address,
        sp_rwd: &mut SupporterReward,
        ctx: &mut TxContext
    ) {
        let sui_value = balance::value(&sp_rwd.balance);
        let to_stake: Coin<SUI> = coin::take(&mut sp_rwd.balance, sui_value, ctx);
        let staked_sui = request_add_stake_non_entry(wrapper, to_stake, validator_address, ctx);
        add_df_with_attach(sp_rwd, staked_sui);
    }

    public entry fun native_unstake(
        wrapper: &mut SuiSystemState,
        sp_rwd: &mut SupporterReward,
        ctx: &mut TxContext
    ) {
        // assert staked before
        let staked_sui = remove_df_with_attach<StakedSui>(sp_rwd);
        let sui = request_withdraw_stake_non_entry(wrapper, staked_sui, ctx);
        balance::join(&mut sp_rwd.balance, sui);
    }

    // ======= Edit ProjectRecord functions ========

    public entry fun add_comment(
        project_record: &mut ProjectRecord,
        reply: Option<ID>, 
        media_link: vector<u8>, 
        content: vector<u8>, 
        clk: &Clock,
        ctx: &mut TxContext
    ) {
        let comment = comment::new_comment(reply, media_link, content, clk, ctx);
        table_vec::push_back<Comment>(&mut project_record.thread, comment);
    }

    public entry fun like_comment(
        project_record: &mut ProjectRecord,
        idx: u64,
        ctx: &TxContext
    ) {
        let comment_bm = table_vec::borrow_mut(&mut project_record.thread, idx);
        comment::like_comment(comment_bm, ctx);
    }

    public entry fun unlike_comment(
        project_record: &mut ProjectRecord,
        idx: u64,
        ctx: &TxContext
    ) {
        let comment_bm = table_vec::borrow_mut(&mut project_record.thread, idx);
        comment::unlike_comment(comment_bm, ctx);
    }

    public entry fun edit_description(
        project_record: &mut ProjectRecord, 
        project_admin_cap: &ProjectAdminCap,
        description: vector<u8>,
        ctx: &TxContext
    ) {
        check_project_cap(project_record, project_admin_cap);
        project_record.description = std::string::utf8(description);
        emit(EditProject {
            project_name: project_record.name,
            editor: ctx.sender(),
        });
    }

    public entry fun edit_image_url(
        project_record: &mut ProjectRecord, 
        project_admin_cap: &ProjectAdminCap,
        image_url: vector<u8>,
        ctx: &TxContext
    ) {
        check_project_cap(project_record, project_admin_cap);
        project_record.image_url = url::new_unsafe_from_bytes(image_url);
        emit(EditProject {
            project_name: project_record.name,
            editor: ctx.sender(),
        });
    }

    public entry fun edit_x_url(
        project_record: &mut ProjectRecord, 
        project_admin_cap: &ProjectAdminCap,
        x_url: vector<u8>,
        ctx: &TxContext
    ) {
        check_project_cap(project_record, project_admin_cap);
        project_record.x = url::new_unsafe_from_bytes(x_url);
        emit(EditProject {
            project_name: project_record.name,
            editor: ctx.sender(),
        });
    }

    public entry fun edit_telegram_url(
        project_record: &mut ProjectRecord, 
        project_admin_cap: &ProjectAdminCap,
        telegram_url: vector<u8>,
        ctx: &TxContext
    ) {
        check_project_cap(project_record, project_admin_cap);
        project_record.telegram = url::new_unsafe_from_bytes(telegram_url);
        emit(EditProject {
            project_name: project_record.name,
            editor: ctx.sender(),
        });
    }

    public entry fun edit_discord_url(
        project_record: &mut ProjectRecord, 
        project_admin_cap: &ProjectAdminCap,
        discord_url: vector<u8>,
        ctx: &TxContext
    ) {
        check_project_cap(project_record, project_admin_cap);
        project_record.discord = url::new_unsafe_from_bytes(discord_url);
        emit(EditProject {
            project_name: project_record.name,
            editor: ctx.sender(),
        });
    }

    public entry fun edit_website_url(
        project_record: &mut ProjectRecord, 
        project_admin_cap: &ProjectAdminCap,
        website_url: vector<u8>,
        ctx: &TxContext
    ) {
        check_project_cap(project_record, project_admin_cap);
        project_record.website = url::new_unsafe_from_bytes(website_url);
        emit(EditProject {
            project_name: project_record.name,
            editor: ctx.sender(),
        });
    }

    public entry fun edit_github_url(
        project_record: &mut ProjectRecord, 
        project_admin_cap: &ProjectAdminCap,
        github_url: vector<u8>,
        ctx: &TxContext
    ) {
        check_project_cap(project_record, project_admin_cap);
        project_record.github = url::new_unsafe_from_bytes(github_url);
        emit(EditProject {
            project_name: project_record.name,
            editor: ctx.sender(),
        });
    }

    // ======= ProjectRecord Get functions ========

    public fun project_name(project_record: &ProjectRecord): std::ascii::String {
        project_record.name
    }

    public fun project_description(project_record: &ProjectRecord): std::string::String {
        project_record.description
    }

    public fun project_image_url(project_record: &ProjectRecord): Url {
        project_record.image_url
    }

    public fun project_x_url(project_record: &ProjectRecord): Url {
        project_record.x
    }

    public fun project_telegram_url(project_record: &ProjectRecord): Url {
        project_record.telegram
    }

    public fun project_discord_url(project_record: &ProjectRecord): Url {
        project_record.discord
    }

    public fun project_website_url(project_record: &ProjectRecord): Url {
        project_record.website
    }

    public fun project_github_url(project_record: &ProjectRecord): Url {
        project_record.github
    }

    public fun project_balance_value(project_record: &ProjectRecord): u64 {
        balance::value<SUI>(&project_record.balance)
    }

    public fun project_ratio(project_record: &ProjectRecord): u64 {
        project_record.ratio
    }

    public fun project_start_time_ms(project_record: &ProjectRecord): u64 {
        project_record.start_time_ms
    }

    public fun project_end_time_ms(project_record: &ProjectRecord): u64 {
        project_record.end_time_ms
    }

    public fun project_total_supply(project_record: &ProjectRecord): u64 {
        project_record.total_supply
    }

    public fun project_amount_per_sui(project_record: &ProjectRecord): u64 {
        project_record.amount_per_sui
    }

    public fun project_remain(project_record: &ProjectRecord): u64 {
        project_record.remain
    }

    public fun project_current_supply(project_record: &ProjectRecord): u64 {
        project_record.current_supply
    }

    public fun project_total_transactions(project_record: &ProjectRecord): u64 {
        project_record.total_transactions
    }

    public fun project_min_value_sui(project_record: &ProjectRecord): u64 {
        project_record.min_value_sui
    }

    public fun project_max_value_sui(project_record: &ProjectRecord): u64 {
        project_record.max_value_sui
    }

    public fun project_participants_number(project_record: &ProjectRecord): u64 {
        table_vec::length<address>(&project_record.participants)
    }

    public fun project_participants(project_record: &ProjectRecord): &TableVec<address> {
        &project_record.participants
    }

    public fun project_minted_per_user(project_record: &ProjectRecord): &Table<address, u64> {
        &project_record.minted_per_user
    }

    public fun project_thread(project_record: &ProjectRecord): &TableVec<Comment> {
        &project_record.thread
    }

    public fun project_admin_cap_to(project_admin_cap: &ProjectAdminCap): ID {
        project_admin_cap.to
    }

    // ======= Admin functions ========
    // In case of ProjectAdminCap is lost
    public fun cancel_project(_: &AdminCap, project_record: &mut ProjectRecord) {
        project_record.cancel = true;
    }

    #[allow(lint(self_transfer))]
    public fun take_remain(_: &AdminCap, project_record: &mut ProjectRecord, ctx: &mut TxContext) {
        assert!(project_record.cancel, EProjectNotCanceled);
        assert!(project_record.current_supply == 0, ETakeAwayNotCompleted);
        let sui_value = balance::value<SUI>(&project_record.balance);
        let remain = coin::take<SUI>(&mut project_record.balance, sui_value, ctx);
        transfer::public_transfer(remain, ctx.sender());
    }

    public fun set_base_fee(_: &AdminCap, deploy_record: &mut DeployRecord, base_fee: u64) {
        deploy_record.base_fee = base_fee;
    }

    public fun set_ratio(_: &AdminCap, deploy_record: &mut DeployRecord, ratio: u64) {
        assert!(ratio <= 5, EImproperRatio);
        deploy_record.ratio = ratio;
    }

    #[allow(lint(self_transfer))]
    public fun withdraw_balance(_: &AdminCap, deploy_record: &mut DeployRecord, ctx: &mut TxContext) {
        let sui_value = balance::value<SUI>(&deploy_record.balance);
        let coin = coin::take<SUI>(&mut deploy_record.balance, sui_value, ctx);
        transfer::public_transfer(coin, ctx.sender());
    }

    // ======= SupporterReward Get functions ========
    public fun sr_name(sp_rwd: &SupporterReward): std::ascii::String {
        sp_rwd.name
    }

    public fun sr_image_url(sp_rwd: &SupporterReward): Url {
        sp_rwd.image_url
    }

    public fun sr_amount(sp_rwd: &SupporterReward): u64 {
        sp_rwd.amount
    }

    public fun sr_balance_value(sp_rwd: &SupporterReward): u64 {
        balance::value<SUI>(&sp_rwd.balance)
    }

    public fun sr_start_time_ms(sp_rwd: &SupporterReward): u64 {
        sp_rwd.start
    }

    public fun sr_end_time_ms(sp_rwd: &SupporterReward): u64 {
        sp_rwd.end
    }

    public fun sr_attach_df_num(sp_rwd: &SupporterReward): u8 {
        sp_rwd.attach_df
    }

    public fun update_image_url(project_record: &ProjectRecord, supporter_reward: &mut SupporterReward) {
        assert!(project_record.name == supporter_reward.name, ENotSameProject);
        supporter_reward.image_url = project_record.image_url;
    }

    fun check_project_cap(project_record: &ProjectRecord, project_admin_cap: &ProjectAdminCap) {
        assert!(object::id(project_record)==project_admin_cap.to, ECapMismatch);
    }

    fun add_df_with_attach<Value: store>(
        sp_rwd: &mut SupporterReward,
        value: Value
    ) {
        let name = type_name::into_string(type_name::get_with_original_ids<Value>());
        sp_rwd.attach_df = sp_rwd.attach_df + 1;
        df::add(&mut sp_rwd.id, name, value);
    }

    fun remove_df_with_attach<Value: store>(
        sp_rwd: &mut SupporterReward
    ): Value {
        let name = type_name::into_string(type_name::get_with_original_ids<Value>());
        // assert attach_coin > 0
        sp_rwd.attach_df = sp_rwd.attach_df - 1;
        let value: Value = df::remove<std::ascii::String, Value>(&mut sp_rwd.id, name);
        value
    }

    #[allow(unused_function)]
    fun exists_df<Value: store>(
        sp_rwd: &SupporterReward
    ): bool {
        let name = type_name::into_string(type_name::get_with_original_ids<Value>());
        df::exists_with_type<std::ascii::String, Value>(&sp_rwd.id, name)
    }

    fun new_supporter_reward(
        name: std::ascii::String,
        image_url: Url,
        amount: u64,
        balance: Balance<SUI>,
        start: u64,
        end: u64,
        ctx: &mut TxContext
    ): SupporterReward {
        SupporterReward {
            id: object::new(ctx),
            name,
            image_url,
            amount,
            balance,
            start,
            end,
            attach_df: 0,
        }
    }

    // ========= Test Functions =========

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(SUIFUND{}, ctx);
    }

    #[test_only]
    public fun new_sp_rwd_for_testing(
        name: std::ascii::String,
        image_url: Url,
        amount: u64,
        balance: Balance<SUI>,
        start: u64,
        end: u64,
        ctx: &mut TxContext
    ): SupporterReward {
        new_supporter_reward(name, image_url, amount, balance, start, end, ctx)
    }

    #[test_only]
    public fun drop_sp_rwd_for_testing(sp_rwd: SupporterReward) {
        let SupporterReward { id, name: _, image_url: _, amount: _, balance, start: _, end: _, attach_df: _ } = sp_rwd;
        balance::destroy_for_testing(balance);
        object::delete(id);
    }

    #[test_only]
    public fun new_project_record_for_testing(
        name: vector<u8>,
        description: vector<u8>,
        image_url: vector<u8>,
        x: vector<u8>,
        telegram: vector<u8>,
        discord: vector<u8>,
        website: vector<u8>,
        github: vector<u8>,
        ratio: u64,
        start_time_ms: u64,
        time_interval: u64,
        total_deposit_sui: u64,
        amount_per_sui: u64,
        min_value_sui: u64,
        max_value_sui: u64,
        ctx: &mut TxContext
    ): ProjectRecord {
        let total_supply = total_deposit_sui / SUI_BASE * amount_per_sui;
        ProjectRecord {
            id: object::new(ctx),
            version: VERSION,
            creator: ctx.sender(),
            name: std::ascii::string(name),
            description: std::string::utf8(description),
            image_url: url::new_unsafe_from_bytes(image_url),
            x: url::new_unsafe_from_bytes(x),
            telegram: url::new_unsafe_from_bytes(telegram),
            discord: url::new_unsafe_from_bytes(discord),
            website: url::new_unsafe_from_bytes(website),
            github: url::new_unsafe_from_bytes(github),
            cancel: false,
            balance: balance::zero<SUI>(),
            ratio,
            start_time_ms,
            end_time_ms: start_time_ms + time_interval,
            total_supply,
            amount_per_sui,
            remain: total_supply,
            current_supply: 0,
            total_transactions: 0,
            min_value_sui,
            max_value_sui,
            participants: table_vec::empty<address>(ctx),
            minted_per_user: table::new<address, u64>(ctx),
            thread: table_vec::empty<Comment>(ctx),
        }
    }

    #[test_only]
    public fun drop_project_record_for_testing(project_record: ProjectRecord) {
        let ProjectRecord {
            id,
            version: _,
            creator: _,
            name: _,
            description: _,
            image_url: _,
            x: _,
            telegram: _,
            discord: _,
            website: _,
            github: _,
            cancel: _,
            balance,
            ratio: _,
            start_time_ms: _,
            end_time_ms: _,
            total_supply: _,
            amount_per_sui: _,
            remain: _,
            current_supply: _,
            total_transactions: _,
            min_value_sui: _,
            max_value_sui: _,
            participants,
            minted_per_user,
            mut thread,
        } = project_record;

        balance::destroy_for_testing<SUI>(balance);
        table_vec::drop<address>(participants);
        table::drop<address, u64>(minted_per_user);

        while (table_vec::length<Comment>(&thread) > 0) {
            let comment = table_vec::pop_back<Comment>(&mut thread);
            comment::drop_comment(comment);
        };
        table_vec::destroy_empty<Comment>(thread);
        object::delete(id);
    }

}

