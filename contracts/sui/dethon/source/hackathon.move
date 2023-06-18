
module dethon::hackathon {
    use sui::url::{Self, Url};
    use std::string;
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    
    /// exception
    const EInvalidStarttime: u64 = 0;
    const EInvalidEndtime: u64 = 1;

    /// Hackathon
    struct Hackathon has key, store {
        id: UID,
        evet_url: Url,
        start_date: u64,
        end_date: u64,
        prize_money: Balance<SUI>
    }

    /// event
    struct HackathonCreated has copy, drop {
        object_id: ID,
        creator: address,
    }


    public entry fun create_hackathon(
        evet_url: vector<u8>, 
        start_date:u64, 
        end_date:u64, 
        ctx: &mut TxContext) {
        assert!(end_date > start_date , EInvalidEndtime);
        assert!(start_date > sui::tx_context::epoch_timestamp_ms(ctx), EInvalidStarttime);
        
        let sender = tx_context::sender(ctx);
        let hackathon = Hackathon {
            id: object::new(ctx),
            evet_url: url::new_unsafe_from_bytes(evet_url),
            start_date: start_date,
            end_date: end_date,
            prize_money: balance::zero<SUI>()
        };

        event::emit(HackathonCreated {
            object_id: object::id(&hackathon),
            creator: sender
        });

        transfer::public_transfer(hackathon, sender);
    }
    
    public entry fun deposit_coin_into_hackathon(
        hackathon: &mut Hackathon,
        coin: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let balance = coin::into_balance(coin);
        balance::join(&mut hackathon.prize_money, balance);
    }
}
