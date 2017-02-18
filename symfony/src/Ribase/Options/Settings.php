<?php

namespace Ribase\Options;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class Settings extends Controller
{

    /* These directories are mapped from other container, please keep it.
     * If you change these paths, be sure that you know what are you doing.
     * Thx for reading.
     */
    protected $mapSettings = "/var/opt/factorio/data/map-gen-settings.json";
    protected $saves = "/var/opt/factorio/saves/";
    protected $mods = "/var/opt/factorio/mods/";
    protected $serverSettings = "/var/opt/factorio/data/server-settings.json";
    protected $factorioDir = "/var/opt/factorio";

    /**
     * @return string
     */
    public function getMapSettings()
    {
        return $this->mapSettings;
    }

    /**
     * @return string
     */
    public function getSaves()
    {
        return $this->saves;
    }

    /**
     * @return string
     */
    public function getMods()
    {
        return $this->mods;
    }

    /**
     * @return string
     */
    public function getServerSettings()
    {
        return $this->serverSettings;
    }

    /**
     * @return string
     */
    public function getFactorioDir()
    {
        return $this->factorioDir;
    }

}