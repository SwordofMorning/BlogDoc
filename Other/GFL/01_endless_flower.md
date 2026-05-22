# Endless Flower

## Z.Start Mission

1. Main Battle Tank: Left HHP `95389`
2. Tactical Mech: Right HHP `95356`
3. Team_6: CC `95357`
4. Team_4: Left HP `95387`
5. Team_3: Right HP `95362`

## I.Turn 1

### 1.1 Airdrop Teams

```cs
AP 10

// 1. airdrop 3 to right-lower-1 HHP
air 3 95364
// 2. airdrop 4 to right middle (zombie) neutral HP
air 4 95395
```

### 1.2 Mech Move 1

```cs
// 1. Move to lower-2 HP
mov mech 95362
// 2. Supply mech
sup mech

// 3. Move to left-4 Griffin HP
mov mech 95387
// 4. Supply mech
sup mech

// 5. Move to left-lower-2
mov mech 95384
// 6. Active mech's Phased-Array Radar (Trace Lock i.e. tl) to lower-2
tlk mech 95380
// 7. Return back to upper-2 Griffin HP
mov mech 95387
// 8. Move to lower-1
mov mech 95385
```

### 1.3 Deploy Team

```cs
// 1. Deploy Team 7 on mech's upper-1 HP
dep 7 95387
// 2. Air drop to mech's right-upper-2 HP
air 7 95333

// 3. Deploy Agent on CC right-1 HP
dep 1 95356
// 4. Move Agent to right-1
mov 1 95398
// 5. Deploy Team 5 on CC right-1 HP
dep 5 95356
// 6. Swap Agent and Team 5
swp 5 1
```

### 1.4 Mech Move 2

```cs
AP 7

// 1. Mech move to center Griffin HP
mov mech 95362
// 2. Supply mech
sup mech
// 3. Move to artillery position 5
mov mech 95370

// 4. Agent airdrop (Hapless Assault) to mech's upper-1 red HP
hap 1 95365
// 5. Agent supply (Tactical Chip: Quick Resupply) mech
rsp mech 95370
// 6. Retreat Agent
ret 1
```

### 1.5 Deploy Scarecrow

```cs
AP 3

// 1. Deploy Scarecrow (replace with Agent) on right-lower Griffin HP
dep 1 95387
// 2. Move to left-lower-2
mov 1 95384
// 3. Use Shadow Predation on lower-1
sha 1 95382

// 4. Swap Team 7 with shadow
swp 7 1
swp 7 shadow
```

### 1.5 Tank

```cs
AP 0

// 1. Tank move tank to lower-2 HP
mov tank 95387
// 2. Supply tank
sup tank

// 3. Tank move to lower-1 artillery position 2
mov tank 95385
// 4. Tank remote bombardment HP-95383 (Not kill)
rba tank 95383
// 5. artillery 2 attack HP-95383
art ap2 95383

// 6. Tank move back to upper HP
mov tank 95387
// 7. Supply tank
sup tank

// 8. Tank move to left-1 of Control Terminal
mov tank 95390
```

### 1.6 Team Move & Mech Move 3

```cs
AP 0

// 1. Airdrop Team 6 to middle neutral HP
air 6 95360

// 2. Artillery 5 (Mech) attack HP-95379
art ap5 95379

// 3. Mech move to artillery 6
mov mech 95368
// 4. Artillery 6 (Mech) attack HP-95374
art ap6 95374

// 5. Mech move to artillery 7
mov mech 95343
// 6. Artillery 7 (Mech) attack HP-95376
art ap7 95376

// 7. Mech move back to artillery 6
mov mech 95368
```

End Turn.

## II. Turn 2

### 2.1 Deploy Team

```cs
AP 18

// 1. Artillery 1 (Scarecrow) attack lower-1 Node-95384
art ap1 95384
// 2. Move Scarecrow to lower-1
mov 1 95384
// 3. Deploy Team 2 on Upper's HP
dep 2 95333
// 4. Supply Team 2
sup 2

// 5. Swap Team 2 with Scarecrow
swp 2 1
// 6. Swap Team 2 with Team 7
swp 2 7
// 7. Swap Team 7 with Scarecrow
swp 1 7
// Now: 7 on 95333; Scarecrow on 95384; 2 on 95382
```

### 2.2 Move & Artillery

```cs
AP 17

// 1. Move tank to right-1 HHP
mov tank 95389
// 2. Supply tank
sup tank

// 3. Move Team 6 to left-1 artillery 3
mov 6 95403
// 4. Artillery 3 (Team 6) attack HP-95379
art ap3 95379

// 5. Deploy Team 8 on T6's upper-2 HP
dep 8 95387
// 6. Supply Team 8
sup 8

// 7. Move Team 8 to lower-1 artillery 2
mov 8 95385
// 8. Artillery 2 (Team 8) attack Node-95381
art ap2 95381

// 9. Swap Team 8 and Team 6
swp 8 6
// 10. Move Team 8 to lower-1 artillery 4
mov 8 95371
// 11. Artillery 4 attack Node-95375
art ap4 95375

// 12. Move Team 8 to lower-2 artillery 5
mov 8 95370
// 13. Artillery 5 attack Node-95377
art ap5 95377
```