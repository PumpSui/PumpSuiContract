module suifund::svg {
    const SVG_part1: vector<u8> = b"data:image/svg+xml,%3Csvg width='800' height='600' xmlns='http://www.w3.org/2000/svg'%3E%3Cdefs%3E%3ClinearGradient id='a' x1='0%25' y1='100%25' x2='0%25' y2='30%25'%3E%3Cstop offset='0%25' stop-color='%23d3d3d3' stop-opacity='0'/%3E%3Cstop offset='100%25' stop-color='%23d3d3d3' stop-opacity='.9'/%3E%3C/linearGradient%3E%3Cmask id='b' maskUnits='userSpaceOnUse' x='0' y='0' width='800' height='600'%3E%3Cpath fill='url(%23a)' d='M0 0h800v600H0z'/%3E%3C/mask%3E%3C/defs%3E%3Cimage href='";
    const SVG_part2: vector<u8> = b"' height='600' width='800' mask='url(%23b)' preserveAspectRatio='none'/%3E%3Ctext x='10' y='400' font-family=''Arial',sans-serif' font-size='32' fill='%23011829' text-anchor='left' dominant-baseline='central' font-weight='700'%3E%3Ctspan x='50' dy='.5em'%3ESupporter Ticket%3C/tspan%3E %3Ctspan x='50' dy='2em'%3EProject: ";
    const SVG_part3: vector<u8> = b"%3C/tspan%3E %3Ctspan x='50' dy='1.2em'%3EAmount: ";
    const SVG_part4: vector<u8> = b"%3C/tspan%3E%3C/text%3E%3Cimage href='https://i.imgur.com/Bwq4FCU.png' x='450' y='400' height='200' width='400'/%3E%3C/svg%3E";

    public(package) fun generateSVG(image_url: vector<u8>, project_name: vector<u8>, amount: vector<u8>): vector<u8>{
        let mut image_data = SVG_part1;
        vector::append(&mut image_data, image_url);
        vector::append(&mut image_data, SVG_part2);
        vector::append(&mut image_data, project_name);
        vector::append(&mut image_data, SVG_part3);
        vector::append(&mut image_data, amount);
        vector::append(&mut image_data, SVG_part4);

        image_data
    }
}