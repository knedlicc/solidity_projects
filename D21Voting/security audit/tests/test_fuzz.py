import brownie
from woke.fuzzer.campaign import Campaign
from woke.fuzzer.decorators import flow, invariant
from woke.fuzzer.random import random_account, random_string


class Test:
    def __init__(self, contract_type) -> None:
        self.owner = random_account()
        self.contract = contract_type.deploy({"from": self.owner})
        self.subjects = []
        self.voters = []
        self.votes = {}

    @flow
    def flow_add_subject(self):
        account = random_account(
            predicate=lambda a: a != self.owner and a not in self.subjects
        )
        subjectName = random_string(min=0, max=20)

        if account in self.subjects or len(subjectName) == 0:
            with brownie.reverts():
                self.contract.addSubject(name, {"from": account})
            return

        self.contract.addSubject(name, {"from": account})
        self.subjects[account] = (subjectName, 0)

    @flow
    def flow_add_voter(self):
        account = random_account(
            predicate=lambda a: a != self.owner and a not in self.voters
        )

        if account in self.voters:
            with brownie.reverts():
                self.contract.addVoter(account, {"from": self.owner})
            return

        self.contract.addVoter(account, {"from": self.owner})
        self.voters.append(account)
        self.votes[account] = []

    
    @flow
    def flow_vote_positive(self):
        if not self.subjects:
            return
        if not self.voters:
            return    
        
        subject = random.choice(self.subjects)
        voter = random.choice(self.voters)

        if subject in self.votes[voter] or len(self.votes[voter]) >= 2:
            with brownie.reverts():
                self.contract.votePositive(subject, {"from": voter})
            return
        
        self.contract.votePositive(subject, {"from": voter})
        self.votes[voter].append(subject)
        subject[1] += 1
    
    @flow
    def flow_vote_negative(self):
        if not self.subjects:
            return
        if not self.voters:
            return   
        
        subject = random.choice(self.subjects)
        voter = random.choice(self.voters)

        if subject in self.votes[voter] or len(self.votes[voter]) != 2:
            with brownie.reverts():
                self.contract.voteNegative(subject, {"from": voter})
            return

        self.contract.voteNegative(subject, {"from": voter})
        self.votes[voter].append(subject)
        subject[1] -= 1


    @invariant
    def invariant_counter_value(self):
        anyone = random_account()
        subjects = self.contract.getSubjects({"from": anyone})

        assert len(self.contract.getSubjects()) == len(self.subjects)
        assert len(self.contract.getVoters()) == len(self.voters)

        for subject in subjects:
            anyone = random_account()
            sub = self.contract.getSubject(subject, {"from": anyone})
            assert self.subjects[subject][0] == sub["name"]
            assert self.subjects[subject][1] == sub["votes"]


def test_counter(D21):
    campaign = Campaign(lambda: Test(D21))
    campaign.run(100, 40)