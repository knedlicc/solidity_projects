from brownie import accounts, D21



def main():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    d21.addSubject("test", {'from': account})
    d21.addSubject("test2", {'from': accounts[1]})
    d21.addSubject("test3", {'from': accounts[2]})
    d21.addSubject("test4", {'from': accounts[3]})
    d21.addVoter(account, {'from': account})
    d21.addVoter(accounts[1], {'from': account})
    d21.addVoter(accounts[2], {'from': account})
    d21.votePositive(account, {'from': accounts[1]})
    d21.votePositive(accounts[1], {'from': accounts[1]})
    d21.voteNegative(accounts[2], {'from': accounts[1]})
    d21.votePositive(account, {'from': accounts[2]})
    d21.votePositive(accounts[3], {'from': accounts[2]})
    d21.voteNegative(accounts[2], {'from': accounts[2]})
    d21.votePositive(accounts[1], {'from': account})
    d21.votePositive(account, {'from': account})

    print(d21.getResults())