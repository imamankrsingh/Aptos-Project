module CharitySupport::RecurringDonation {

    use aptos_framework::signer;
    use aptos_framework::coin::{transfer, Coin};
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::timestamp;

    struct DonationPlan has store, key {
        donor: address,
        charity: address,
        amount: u64,
        last_donation_time: u64,
        interval: u64,  // Interval in seconds
    }

    // Function to create a donation plan
    public fun setup_donation(account: &signer, charity: address, amount: u64, interval: u64) {
        let donor = signer::address_of(account);
        let plan = DonationPlan {
            donor,
            charity,
            amount,
            last_donation_time: timestamp::now_seconds(),
            interval,
        };
        move_to(account, plan);
    }

    // Function to execute the recurring donation
    public fun execute_donation(account: &signer) acquires DonationPlan {
        let plan = borrow_global_mut<DonationPlan>(signer::address_of(account));
        let current_time = timestamp::now_seconds();

        // Ensure enough time has passed to execute the donation
        if (current_time - plan.last_donation_time >= plan.interval) {
            transfer<AptosCoin>(account, plan.charity, plan.amount);
            plan.last_donation_time = current_time;
        }
    }
}
