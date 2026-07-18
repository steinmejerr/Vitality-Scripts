import { Flex, Image, Group, Text, Divider } from "@mantine/core"
import { IconChevronCompactRight } from "@tabler/icons-react"

interface Properties {
    title: string;
}

export const Header = ({ title }: Properties) => {
    const text = title;
    const words = text.split(" ");
    return <>
        <Group gap="sm">
            <Image src="./logo.png" w={90} h={90} />
            <Divider orientation="vertical" size="sm" color="rgba(255,255,255,0.25)" h={70} mt="10px" />
            <Flex direction="column" gap={0} ml={5}>
                {words.map((word, index) => (
                    <Text key={index} fz="2rem" lh={1.1} fw={600} c={index == 1 ? 'teal.3' : 'white'} lts={5.5} tt="uppercase" style={{ textShadow: `0px 0px 10px ${index == 1 ? 'rgba(0,255,255,0.5)' : "rgba(255,255,255,0.5)"}` }}>
                        {word}
                    </Text>
                ))}
            </Flex>
        </Group>
        <Group gap={0}>
            {Array.from({ length: 20 }).map((_, index) => {
                const opacity = (index + 1) / 20;
                return (
                    <IconChevronCompactRight
                        key={index}
                        style={{ width: "18px", height: "18px" }}
                        color={`rgba(99, 230, 190, ${opacity})`}
                    />
                );
            })}
        </Group>

    </>
}