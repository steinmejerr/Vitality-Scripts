import { CharacterType } from "../types/types";

export const CharacterApi: CharacterType = {
  firstname: "Arturo",
  lastname: "Vilchis",
  slot: 1,
  isNew: false
};

export const CharactersApi: CharacterType[] = [
  {
    slot: 1,
    isNew: true
  },
  {
    firstname: "Slot",
    lastname: "Two",
    slot: 2,
    isNew: false
  },
];

export const PlayerApi = {
  ownedSlots: 4,
};

export const SettingsApi = {
  maxSlots: 5,
  canBuy: true,
};
