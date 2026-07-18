import { useState } from "react"
import { Box, Group, Text, Stack, ScrollArea, Button, Flex } from "@mantine/core"
import { useRecoilState, useRecoilValue } from 'recoil'
import { AllCharacters, CanDelete, CurrentCharacter, Lang, Slots } from '../../reducers/atoms'
import { CharacterType } from "../../types/types";
import { fetchNui } from "../../hooks/useNuiEvents";
import classes from './style.module.css'

interface Properties {
    setScreen: (name: string) => void;
    setTitle: (name: string) => void;
}

export const CharacterList = ({ setScreen, setTitle }: Properties) => {
    const lang: any = useRecoilValue(Lang)
    const allCharacters = useRecoilValue(AllCharacters)
    const canDelete = useRecoilValue(CanDelete)
    const [current, setCurrent] = useRecoilState(CurrentCharacter)
    const [cooldown, setCooldown] = useState(false)
    const slots = useRecoilValue(Slots)
    const handleSlot = async (character: CharacterType) => {
        if (cooldown) return;
        if (current && current.slot == character.slot) {
            setCurrent(null)
        } else {
            setCooldown(true)
            setCurrent(character)
            await fetchNui('av_multicharacter', 'setSlot', character.slot)
            setCooldown(false)
        }
    }
    const handlePlay = async () => {
        if (cooldown || !current) return
        setCurrent(null)
        setCooldown(true)
        await fetchNui('av_multicharacter', 'play', current.slot)
        setCooldown(false)
    }
    const handleDelete = () => {
        if (!current) return;
        setScreen("delete")
        setTitle(lang.title_character_delete)
    }
    const handleRegister = () => {
        setScreen("register")
        setTitle(lang.title_register_character)
    }
    return <Box mt="md" ml="sm">
        <ScrollArea scrollbars="y"
            offsetScrollbars
            scrollbarSize={3}
            h={350}
        >
            <Stack gap="sm" >
                {allCharacters.map((character, index) => (
                    <Box key={index} 
                        className={current && current.slot == character.slot ? classes.selected : classes.character} 
                        onClick={() => {
                            if((index+1) > slots) return;
                            handleSlot(character)
                        }}
                    >
                        <Group>
                            <Box className={classes.slotBox}>{character.slot}</Box>
                            <Flex direction="column" gap={0}>
                                {(index + 1) > slots ?
                                    <>
                                        <Group gap="xs">
                                            <Text c="white" lts={1.25}>{lang.locked}</Text>
                                            <Text c="white" lts={1.25}>{lang.slot}</Text>
                                        </Group>
                                    </>
                                    :
                                    <>
                                        <Group gap="xs">
                                            <Text c="white" lts={1.25}>{character.firstname ? character.firstname : lang.available}</Text>
                                            <Text c="white" lts={1.25}>{character.lastname ? character.lastname : lang.slot}</Text>
                                        </Group>
                                        <Text fz="sm" c="gray.3" lts={1.55}>{character.job}</Text>
                                    </>
                                }
                            </Flex>
                        </Group>
                    </Box>
                ))}
            </Stack>
        </ScrollArea>
        {current &&
            <>
                {current.isNew ? 
                    <>
                        <Button className={classes.select} autoContrast color="rgba(99, 230, 190, 0.55)" c="white" fw={500} mt="sm" fullWidth lts={1} onClick={() => {
                            if (!current) return;
                            handleRegister()
                        }}>{lang.create_character_button}</Button>
                    </>
                :
                    <Group justify="space-between" mt="sm" grow>
                        {canDelete &&
                            <Button className={classes.delete} autoContrast color="rgba(240, 62, 62, 0.55)" c="white" fw={500} lts={1} onClick={() => {
                                if (!current) return;
                                handleDelete()
                            }}>{lang.delete_character_button}</Button>
                        }
                        <Button className={classes.select} autoContrast color="rgba(99, 230, 190, 0.55)" c="white" fw={500} lts={1} onClick={() => {
                            if (!current) return;
                            handlePlay()
                        }}>{lang.select_character_button}</Button>
                    </Group>
                }
            </>
        }
    </Box>
}
