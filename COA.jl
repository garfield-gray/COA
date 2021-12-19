using IntervalArithmetic
using LinearAlgebra
using Distributions
using Statistics
using Plots

#in the name of God
#Defining COA parameters
Nvar = 2
Npop = 10
obj = f1
Cons = 1.5                                    #Consentration of egg laying
MAXGEN = 50                                   #maximum generations
a11 = -5; a12 = 5; a21 = -5; a22 = 5;          #limits
A = IntervalBox(a11..a12, a21..a22)            #the region
###############################################################################################
Current = rand(Uniform(0, 1), Npop, Nvar)      #Genesis
Current *= Diagonal([(a12-a11);(a22-a21)])     #stretching it
Current += repeat([a11 a21], Npop, 1)          #putting it in place

flag = 0

for i in 1:MAXGEN                                                    #for each generation
    Next = rand(1, Nvar); Next = Next[1:end .!=1,:];                 #preparing the next Gen & makin it empty
    eggnum = abs.(ceil.(Int, rand(Normal(11, 4), Npop))).+1              #eggs each cuckoo lays(it could make 0|-)
    for j in 1:Npop                                                      #for each bird   
        offsprings = repeat(Current[j,:]',eggnum[j],1)                   #make the potential eggs
        movements = rand(Uniform(-1, 1), eggnum[j], Nvar)                #make movements
        movements *= (Diagonal([(a12-a11);(a22-a21)])./(Npop*Cons^i))    #stretch
        offsprings += movements                                          #put them inplace
        profit = obj(offsprings)                                         #evaluation
        m = median(profit, dims=1)                                       #find meadian
        index = findall(profit.<m)                                       #find vulnerables
        offsprings = offsprings[index,:]                                 #dismiss them
        Next = [Next; offsprings]                                        #push them into the Next Gen
    end
    N, o = size(Next)                                                #finding size of new population
    value = obj(Next)                                                #overall evaluation
    bestind = argmin(value)                                          #finding the index of the best
    best = Next[bestind,:]'
    migdes = Next - repeat(best, N , 1)                              #destination of migration
    v = Diagonal(rand(N))*migdes                                     #not all of them make it to the best
    Next = Next + v                                                  #migration
    q = quantile(value, (1:Npop)./length(value))                     #best Npop's
    bestNpopind = findall(value .<= q[Npop])                         #their indices
    Next = Next[bestNpopind,:]                                       #dismiss to the Npop
    #print(round.(best, digits = 3))
    print(best)
    print('\n')
    Current = Next                                                   #regenerating
end
#report the best
