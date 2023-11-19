import brownie
import pytest
from brownie import a, chain, D21, accounts


def test_deploy():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    start_time = d21.getRemainingTime()
    expected_time = 604800
    assert start_time == expected_time


def test_add_subject():
    account = accounts[0]
    name = "test"
    d21 = D21.deploy({'from': account})
    d21.addSubject(name, {'from': account})
    expectedAddress = account
    assert d21.getSubjects()[0] == expectedAddress

def test_add_subject_negative_created():
    account = accounts[0]
    name = "test"
    d21 = D21.deploy({'from': account})
    d21.addSubject(name, {'from': account})
    with brownie.reverts("You already have registered a subject"):
        d21.addSubject(name, {'from': account})
    expectedAddress = account
    assert d21.getSubjects()[0] == expectedAddress

def test_add_subject_negative_empty():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    with brownie.reverts("Name is empty"):
        d21.addSubject("", {'from': account})

def test_add_voter():
    account = accounts[0]
    voter = accounts[1]
    d21 = D21.deploy({'from': account})
    d21.addVoter(voter, {'from': account})
    extected = 1
    assert d21.getVoter(voter) == extected

def test_add_voter_revert_not_owner():
    account = accounts[0]
    voter = accounts[1]
    d21 = D21.deploy({'from': account})
    with brownie.reverts("You are not the owner"):
        d21.addVoter(voter, {'from': accounts[1]})

def test_add_voter_revert_exists():
    account = accounts[0]
    voter = accounts[1]
    d21 = D21.deploy({'from': account})
    d21.addVoter(voter, {'from': account})
    with brownie.reverts("This address is already a voter"):
        d21.addVoter(voter, {'from': account})

def test_get_subjects():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    expected = []
    assert d21.getSubjects() == expected

def test_get_subject():
    account = accounts[0]
    name = "test"
    d21 = D21.deploy({'from': account})
    d21.addSubject(name, {'from': account})
    expectedName = name
    assert d21.getSubject(account)[0] == expectedName

def test_get_subject_zero():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    with brownie.reverts("This address is not a subject"):
        d21.getSubject(account)

def test_vote_positive():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    d21.addVoter(accounts[1], {'from': account})
    d21.addSubject("test", {'from': account})
    d21.votePositive(account, {'from': accounts[1]})
    expected = 1
    assert d21.getSubject(account)[1] == expected

def test_vote_positive_not_voter():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    d21.addSubject("test", {'from': account})
    with brownie.reverts("You are not a voter"):
        d21.votePositive(account, {'from': accounts[1]})

def test_vote_positive_no_subject():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    d21.addVoter(accounts[1], {'from': account})
    with brownie.reverts("This address is not a subject"):
        d21.votePositive(account, {'from': accounts[1]})

def test_vote_positive_already_voted():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    d21.addVoter(accounts[1], {'from': account})
    d21.addSubject("test", {'from': account})
    d21.votePositive(account, {'from': accounts[1]})
    with brownie.reverts("You already voted for this subject"):
        d21.votePositive(account, {'from': accounts[1]})

def test_vote_positive_already_voted_2times():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    d21.addSubject("test", {'from': account})
    d21.addSubject("test2", {'from': accounts[1]})
    d21.addSubject("test3", {'from': accounts[2]})
    d21.addVoter(accounts[1], {'from': account})
    d21.votePositive(account, {'from': accounts[1]})
    d21.votePositive(accounts[1], {'from': accounts[1]})
    with brownie.reverts("You already voted 2 times"):
        d21.votePositive(accounts[2], {'from': accounts[1]})


def test_vote_positive_already_voted_3times():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    d21.addSubject("test", {'from': account})
    d21.addSubject("test2", {'from': accounts[1]})
    d21.addSubject("test3", {'from': accounts[2]})
    d21.addSubject("test4", {'from': accounts[3]})
    d21.addVoter(accounts[1], {'from': account})
    d21.votePositive(account, {'from': accounts[1]})
    d21.votePositive(accounts[1], {'from': accounts[1]})
    d21.voteNegative(accounts[2], {'from': accounts[1]})
    with brownie.reverts("You already voted 3 times"):
        d21.votePositive(accounts[3], {'from': accounts[1]})

def test_vote_negative():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    d21.addVoter(accounts[1], {'from': account})
    d21.addSubject("test", {'from': account})
    d21.addSubject("test2", {'from': accounts[1]})
    d21.addSubject("test3", {'from': accounts[2]})
    d21.votePositive(account, {'from': accounts[1]})
    d21.votePositive(accounts[1], {'from': accounts[1]})
    d21.voteNegative(accounts[2], {'from': accounts[1]})
    expected = -1
    assert d21.getSubject(accounts[2])[1] == expected

def test_vote_negative_not_voter():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    d21.addSubject("test", {'from': account})
    with brownie.reverts("You are not a voter"):
        d21.voteNegative(account, {'from': accounts[1]})

def test_vote_negative_no_subject():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    d21.addVoter(accounts[1], {'from': account})
    with brownie.reverts("This address is not a subject"):
        d21.voteNegative(account, {'from': accounts[1]})

def test_vote_negative_already_voted():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    d21.addVoter(accounts[1], {'from': account})
    d21.addSubject("test", {'from': account})
    d21.addSubject("test2", {'from': accounts[1]})
    d21.addSubject("test3", {'from': accounts[2]})
    d21.addSubject("test4", {'from': accounts[3]})
    d21.votePositive(account, {'from': accounts[1]})
    d21.votePositive(accounts[1], {'from': accounts[1]})
    d21.voteNegative(accounts[2], {'from': accounts[1]})
    with brownie.reverts("You already voted negative"):
        d21.voteNegative(accounts[3], {'from': accounts[1]})

def test_vote_negative_not_voted_positive():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    d21.addVoter(accounts[1], {'from': account})
    d21.addSubject("test", {'from': account})
    d21.addSubject("test2", {'from': accounts[1]})
    d21.votePositive(account, {'from': accounts[1]})
    with brownie.reverts("You did not vote positive for 2 subjects"):
        d21.voteNegative(accounts[1], {'from': accounts[1]})

def test_get_remaining_time():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    expected = 604800
    assert d21.getRemainingTime() == expected

def test_get_results():
    account = accounts[0]
    d21 = D21.deploy({'from': account})
    d21.addSubject("test", {'from': account})
    expected = d21.getSubject(account)
    assert d21.getResults()[0] == expected

def test_sort_results():
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
    expected = [d21.getSubject(account), d21.getSubject(accounts[1]), d21.getSubject(accounts[3]), d21.getSubject(accounts[2])]
    assert d21.getResults() == expected