import { atom } from "recoil";
import { CharacterType } from "../types/types";
import { CharactersApi } from "../api/character";

export const Lang = atom<Object>({
  key: "lang",
  default: {},
});

export const Settings = atom<Object>({
  key: "settings",
  default: {},
});

export const AllCharacters = atom<CharacterType[]>({
  key: "allCharacters",
  default: CharactersApi,
})

export const CurrentCharacter = atom<null | CharacterType>({
  key: "currentCharacter",
  default: null
})

export const Slots = atom<number>({
  key: "Slots",
  default: 3
})

export const CanDelete = atom<boolean>({
  key: "canDelete",
  default: false
})