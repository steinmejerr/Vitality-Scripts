import { Box, Group, Button, Text, NumberInput, Title } from "@mantine/core"
import { useRecoilState, useRecoilValue } from "recoil"
import { CurrentCharacter, Lang } from "../../reducers/atoms"
import { useState } from "react";
import { fetchNui } from "../../hooks/useNuiEvents";
import classes from './style.module.css'

interface Properties {
    setScreen: (name: string) => void;
    setTitle: (name: string) => void;
}

export const DeletePanel = ({ setScreen, setTitle }: Properties) => {
    const lang: any = useRecoilValue(Lang)
    const [character, setCharacter] = useRecoilState(CurrentCharacter)
    const [answer, setAnswer] = useState(0)
    const handleCancel = () => {
        setCharacter(null)
        setTitle(lang.title_character_selection)
        setScreen("characters")
    }
    const handleConfirm = () => {
        fetchNui("av_multicharacter", "delete", character)
    }
    return (
        <Box mt="md" ml="xs">
            <Title order={3} tt="uppercase">{lang.warning_header}</Title>
            <Text maw={350}>
                <p>{lang.delete_text_1}</p>
                <p><b>{lang.delete_text_2}</b></p>
            </Text>
            <NumberInput classNames={classes} label={lang.delete_label} placeholder={lang.delete_placeholder} allowDecimal={false} allowLeadingZeros={false} allowNegative={false} onChange={(e) => { setAnswer(Number(e)) }} hideControls />
            <Group justify="space-between" mt="md" grow>
                <Button className={classes.delete} autoContrast color="rgba(240, 62, 62, 0.55)" c="white" fw={500} lts={1} onClick={() => {
                    if (!character) return;
                    handleCancel()
                }}>{lang.delete_cancel_button}</Button>
                <Button className={classes.select} autoContrast color="rgba(99, 230, 190, 0.55)" c="white" fw={500} lts={1} onClick={() => {
                    if (!character) return;
                    handleConfirm()
                }} disabled={answer !== 4}>{lang.delete_button}</Button>
            </Group>
        </Box>
    )
}
